import Foundation

/// A stateful multi-step interaction mounted into a ``Teleroute``.
///
/// Flows keep one session per `chatId + userId` pair in the router's configured
/// `TelerouteFlowStorage` and can route messages, commands, and callback queries
/// based on the active step.
public protocol TelerouteFlow: Sendable {
    associatedtype Step: RawRepresentable & Hashable & Sendable where Step.RawValue == String

    /// Stable flow identifier stored in the session.
    static var id: String { get }

    /// Overrides ``TelerouteConfiguration/flowSessionTTL`` for this flow.
    ///
    /// `nil` (the default) uses the configured value.
    static var sessionTTL: Duration? { get }

    /// Registers the flow's step handlers.
    func boot(flow: TelerouteFlowGroup<Self>)
}

public extension TelerouteFlow {
    static var id: String {
        String(reflecting: Self.self)
    }

    static var sessionTTL: Duration? { nil }
}

/// Async handler invoked for a matched flow step.
public typealias TelerouteFlowHandler<Flow: TelerouteFlow> = @Sendable (
    _ context: TelerouteFlowContext<Flow>
) async throws -> Void

/// Flow-specific registration API for step handlers.
public final class TelerouteFlowGroup<Flow: TelerouteFlow>: Sendable {
    let storage: TelerouteStorage
    let commandPrefix: [String]
    let callbackPrefix: [String]
    let inheritedMiddlewares: [any TelerouteMiddleware<TelerouteContext>]
    let inheritedGuards: [any TelerouteGuard]

    init(
        storage: TelerouteStorage,
        commandPrefix: [String] = [],
        callbackPrefix: [String] = [],
        inheritedMiddlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        inheritedGuards: [any TelerouteGuard] = []
    ) {
        self.storage = storage
        self.commandPrefix = commandPrefix
        self.callbackPrefix = callbackPrefix
        self.inheritedMiddlewares = inheritedMiddlewares
        self.inheritedGuards = inheritedGuards
    }

    /// Registers a command that starts or restarts the flow at the supplied step.
    public func start(
        _ path: String,
        at step: Flow.Step,
        botUsername: String? = nil,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility] = [.default],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        queue: TelerouteQueueScope? = nil,
        use handler: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) {
        let name = TeleroutePath.commandName(prefix: self.commandPrefix, path: path)
        let hasGuard = self.inheritedGuards.isEmpty == false || guards.isEmpty == false
        var resolvedMiddlewares = TelerouteMiddlewareComposer.resolve(
            inheritedMiddlewares: self.inheritedMiddlewares,
            inheritedGuards: self.inheritedGuards,
            guards: guards,
            middlewares: middlewares
        )
        if let queue {
            let queueMiddleware = TelerouteCommandQueueMiddleware(
                queue: self.storage.commandQueue,
                routeName: name,
                scope: queue
            )
            let insertionIndex = hasGuard ? 1 : 0
            resolvedMiddlewares.insert(queueMiddleware, at: insertionIndex)
        }
        if let description {
            for visibility in visibility {
                self.storage.appendPublishedCommand(
                    .init(name: name, description: description, visibility: visibility)
                )
            }
        }
        let flowQueueMiddleware = TelerouteFlowQueueMiddleware(queue: self.storage.flowQueue)
        let insertionIndex = hasGuard ? 1 : 0
        resolvedMiddlewares.insert(flowQueueMiddleware, at: insertionIndex)

        self.storage.appendCommandRoute(
            .init(
                name: name,
                botUsername: botUsername,
                middlewares: resolvedMiddlewares,
                handler: { context in
                    try await context.start(Flow.self, at: step)
                    try await handler(context)
                    return .none
                }
            ),
            signature: hasGuard == false
                ? .init(kind: .command, name: name, botUsername: botUsername)
                : nil
        )
    }

    /// Registers a handler for any non-callback message at the supplied step.
    public func message(
        at step: Flow.Step,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping TelerouteFlowHandler<Flow>
    ) {
        self.register(
            step: step,
            matcher: .message,
            signatureName: "*",
            guards: guards,
            middlewares: middlewares,
            handler: handler
        )
    }

    /// Registers a command handler for a specific step.
    public func command(
        _ path: String,
        at step: Flow.Step,
        botUsername: String? = nil,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping TelerouteFlowHandler<Flow>
    ) {
        let name = TeleroutePath.commandName(prefix: self.commandPrefix, path: path)
        self.register(
            step: step,
            matcher: .command(
                name: name,
                botUsername: botUsername
            ),
            signatureName: name,
            guards: guards,
            middlewares: middlewares,
            handler: handler
        )
    }

    /// Registers a callback handler for a specific step.
    public func callback(
        _ path: String,
        at step: Flow.Step,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping TelerouteFlowHandler<Flow>
    ) {
        let pattern = TelerouteCallbackPattern(prefix: self.callbackPrefix, path: path)
        self.register(
            step: step,
            matcher: .callback(pattern),
            signatureName: pattern.routeDescription,
            guards: guards,
            middlewares: middlewares,
            handler: handler
        )
    }

    /// Renders one typed button description in this flow's route scope.
    public func render(_ button: TelerouteButton) throws -> InlineKeyboardButton {
        try self.routeScope.render(button)
    }

    /// Renders callback button descriptions into Telegram keyboard rows.
    public func keyboard(_ rows: [[TelerouteButton]]) throws -> InlineKeyboardMarkup {
        try self.routeScope.keyboard(rows)
    }

    private func register(
        step: Flow.Step,
        matcher: TelerouteFlowRouteMatcher,
        signatureName: String,
        guards: [any TelerouteGuard],
        middlewares: [any TelerouteMiddleware<TelerouteContext>],
        handler: @escaping TelerouteFlowHandler<Flow>
    ) {
        let hasGuard = self.inheritedGuards.isEmpty == false || guards.isEmpty == false
        let resolvedMiddlewares = TelerouteMiddlewareComposer.resolve(
            inheritedMiddlewares: self.inheritedMiddlewares,
            inheritedGuards: self.inheritedGuards,
            guards: guards,
            middlewares: middlewares
        )
        self.storage.appendFlowRoute(
            .init(
                flowID: Flow.id,
                step: step.rawValue,
                matcher: matcher,
                middlewares: resolvedMiddlewares,
                handler: { context in
                    let flowContext = try TelerouteFlowContext<Flow>(context: context)
                    try await handler(flowContext)
                    return .none
                }
            ),
            signature: hasGuard == false
                ? .init(
                    kind: matcher.signatureKind,
                    name: signatureName,
                    botUsername: matcher.botUsername,
                    flowID: Flow.id,
                    step: step.rawValue
                )
                : nil
        )
    }

    var routeScope: TelerouteRoutes {
        .init(
            storage: self.storage,
            commandPrefix: self.commandPrefix,
            callbackPrefix: self.callbackPrefix,
            inheritedMiddlewares: self.inheritedMiddlewares,
            inheritedGuards: self.inheritedGuards
        )
    }
}

private extension TelerouteFlowRouteMatcher {
    var signatureKind: TelerouteRouteSignature.Kind {
        switch self {
        case .message:
            .flowMessage
        case .command:
            .flowCommand
        case .callback:
            .flowCallback
        }
    }

    var botUsername: String? {
        switch self {
        case let .command(_, botUsername):
            botUsername
        case .message, .callback:
            nil
        }
    }
}

/// Typed context passed to flow step handlers.
public struct TelerouteFlowContext<Flow: TelerouteFlow>: Sendable {
    /// Underlying router context.
    public let context: TelerouteContext
    /// Active flow session.
    public let session: TelerouteFlowSession
    /// Decoded current flow step.
    public let step: Flow.Step

    init(context: TelerouteContext) throws {
        guard let session = context.activeFlow else {
            throw TelerouteError.flowControllerMissing
        }
        guard session.id == Flow.id else {
            throw TelerouteError.invalidFlowStep(flowID: Flow.id, step: session.step)
        }
        guard let step = Flow.Step(rawValue: session.step) else {
            throw TelerouteError.invalidFlowStep(flowID: Flow.id, step: session.step)
        }
        self.context = context
        self.session = session
        self.step = step
    }

    /// Accumulated flow values for the active session.
    public var values: TelerouteFlowValues {
        self.session.values
    }

    /// Replaces the current flow session with a new step and values.
    public func restart(
        at step: Flow.Step,
        values: [String: String] = [:]
    ) async throws {
        try await self.context.start(Flow.self, at: step, values: values)
    }

    /// Moves the current flow to another step, merging new values into the session.
    ///
    /// - Throws: ``TelerouteError/flowSessionEnded(flowID:)`` when the session
    ///   has already ended, and
    ///   ``TelerouteError/flowSessionReplaced(expected:found:)`` when another
    ///   flow has taken over this chat/user scope.
    public func transition(
        to step: Flow.Step,
        merging values: [String: String] = [:]
    ) async throws {
        let ttl = self.resolvedSessionTTL
        try await self.mutateSession { current in
            current.advanced(
                step: step.rawValue,
                values: current.values.merging(values),
                ttl: ttl
            )
        }
    }

    /// Updates the current step values without changing the active step.
    ///
    /// - Throws: the same errors as ``transition(to:merging:)``.
    public func update(
        merging values: [String: String]
    ) async throws {
        let ttl = self.resolvedSessionTTL
        try await self.mutateSession { current in
            current.advanced(values: current.values.merging(values), ttl: ttl)
        }
    }

    /// The TTL governing this flow's sessions: the flow's own override, or the
    /// router's configured default.
    private var resolvedSessionTTL: Duration? {
        Flow.sessionTTL ?? self.context.flowSessionTTL
    }

    /// Applies a transformation to the live session, refusing to write when the
    /// session has ended or been taken over.
    ///
    /// The previous implementation fell back to this context's own session
    /// snapshot (`current ?? self.session`), which silently **recreated** a
    /// session a handler had just finished. Validating instead means a write
    /// only ever advances a session that is genuinely still active — and
    /// because the closure throws before returning a value, neither the default
    /// `updateSession` implementation nor an atomic backend performs a write.
    private func mutateSession(
        _ transform: @Sendable (TelerouteFlowSession) -> TelerouteFlowSession
    ) async throws {
        let storage = try self.context.requireFlowStorage()
        let key = try self.context.requireFlowKey()
        try await storage.updateSession(for: key) { current in
            guard let current else {
                throw TelerouteError.flowSessionEnded(flowID: Flow.id)
            }
            guard current.id == Flow.id else {
                throw TelerouteError.flowSessionReplaced(
                    expected: Flow.id,
                    found: current.id
                )
            }
            return transform(current)
        }
    }

    /// Completes the current flow session successfully.
    ///
    /// Ends the session exactly as ``TelerouteRequestContext/cancelFlow()``
    /// does, but reports the outcome as ``TelerouteFlowOutcome/finished`` to
    /// the metrics sink — so completion and abandonment are distinguishable.
    public func finish() async throws {
        try await self.context.endFlow(outcome: .finished)
    }

    /// Abandons the current flow session, reported as
    /// ``TelerouteFlowOutcome/cancelled``.
    public func cancel() async throws {
        try await self.context.endFlow(outcome: .cancelled)
    }
}

/// A flow step context is an ordinary request context, so every Telegram
/// helper — media, moderation, reactions, pinning, edit-target resolution,
/// keyboards — is available directly on it. ``TelerouteFlowContext/context``
/// remains public for code that reaches the core context explicitly.
extension TelerouteFlowContext: TelerouteRequestContext {
    public var coreContext: TelerouteContext { self.context }
}

public extension TelerouteRoutes {
    /// Mounts a flow into the current route scope.
    func flow<Flow: TelerouteFlow>(_ flow: Flow) {
        self.storage.registerFlow()
        flow.boot(
            flow: .init(
                storage: self.storage,
                commandPrefix: self.commandPrefix,
                callbackPrefix: self.callbackPrefix,
                inheritedMiddlewares: self.inheritedMiddlewares,
                inheritedGuards: self.inheritedGuards
            )
        )
    }
}

@_spi(Testing)
public extension TelerouteRuntime {
    /// Mounts a flow at the router root.
    func flow<Flow: TelerouteFlow>(_ flow: Flow) {
        self.routeScope.flow(flow)
    }
}
