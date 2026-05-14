import Foundation

/// Key used by rate-limiting middleware.
public struct TelerouteRateLimitKey: Sendable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Shared rate-limit key builders for middleware.
public enum TelerouteRateLimitScope: Sendable {
    case chat
    case user
    case chatUser
    case callbackData
    case command
    case custom(@Sendable (TelerouteContext) -> TelerouteRateLimitKey?)

    func key(for context: TelerouteContext) -> TelerouteRateLimitKey? {
        switch self {
        case .chat:
            context.chatId.map { .init("chat|\($0)") }
        case .user:
            context.userId.map { .init("user|\($0)") }
        case .chatUser:
            context.flowKey.map { .init("chatUser|\($0.chatId)|\($0.userId.map(String.init) ?? "none")") }
        case .callbackData:
            context.callbackData.map { .init("callback|\(context.chatId.map(String.init) ?? "none")|\(context.userId.map(String.init) ?? "none")|\($0)") }
        case .command:
            context.command.map { .init("command|\(context.chatId.map(String.init) ?? "none")|\(context.userId.map(String.init) ?? "none")|\($0.rawValue)|\($0.argumentsText ?? "")") }
        case let .custom(makeKey):
            makeKey(context)
        }
    }
}

/// Drops updates that repeat within the configured interval.
public struct TelerouteThrottleMiddleware: TelerouteMiddleware, Sendable {
    private let interval: Duration
    private let scope: TelerouteRateLimitScope
    private let gate: TelerouteThrottleGate

    public init(
        interval: Duration,
        scope: TelerouteRateLimitScope = .chatUser
    ) {
        self.interval = interval
        self.scope = scope
        self.gate = TelerouteThrottleGate()
    }

    public func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) async throws {
        guard let key = self.scope.key(for: context) else {
            try await next(context)
            return
        }
        guard await self.gate.claim(key: key.rawValue, interval: self.interval) else {
            return
        }
        try await next(context)
    }
}

/// Delays handling until the configured interval passes without a newer update
/// for the same key. Superseded updates are dropped.
public struct TelerouteDebounceMiddleware: TelerouteMiddleware, Sendable {
    private let interval: Duration
    private let scope: TelerouteRateLimitScope
    private let gate: TelerouteDebounceGate

    public init(
        interval: Duration,
        scope: TelerouteRateLimitScope = .chatUser
    ) {
        self.interval = interval
        self.scope = scope
        self.gate = TelerouteDebounceGate()
    }

    public func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) async throws {
        guard let key = self.scope.key(for: context) else {
            try await next(context)
            return
        }

        let generation = await self.gate.reserve(key: key.rawValue)
        try await Task.sleep(for: self.interval)
        guard await self.gate.shouldRun(key: key.rawValue, generation: generation) else {
            return
        }

        try await next(context)
        await self.gate.finish(key: key.rawValue, generation: generation)
    }
}

private actor TelerouteThrottleGate {
    private let clock = ContinuousClock()
    private var expirations: [String: ContinuousClock.Instant] = [:]

    func claim(key: String, interval: Duration) -> Bool {
        let now = self.clock.now
        self.expirations = self.expirations.filter { $0.value > now }
        guard self.expirations[key].map({ $0 > now }) != true else {
            return false
        }
        self.expirations[key] = now.advanced(by: interval)
        return true
    }
}

private actor TelerouteDebounceGate {
    private var generations: [String: Int] = [:]

    func reserve(key: String) -> Int {
        let generation = self.generations[key, default: 0] + 1
        self.generations[key] = generation
        return generation
    }

    func shouldRun(key: String, generation: Int) -> Bool {
        self.generations[key] == generation
    }

    func finish(key: String, generation: Int) {
        if self.generations[key] == generation {
            self.generations[key] = nil
        }
    }
}
