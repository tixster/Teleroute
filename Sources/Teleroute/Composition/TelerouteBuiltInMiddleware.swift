import Foundation
import Logging

/// Middleware shipped with Teleroute. Attach them to routes or groups via the
/// `middlewares:` parameter.

/// Logs handler entry and exit around a matched route.
public struct TelerouteAccessLogMiddleware: TelerouteMiddleware {
    private let logger: Logger

    /// Creates an access-logging middleware with the supplied logger.
    public init(logger: Logger) {
        self.logger = logger
    }

    /// Creates an access-logging middleware with a logger under the given label.
    public init(label: String) {
        self.logger = Logger(label: label)
    }

    public func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) async throws {
        self.logger.info(
            "before route",
            metadata: [
                "chat_id": .string(context.chatId.map(String.init) ?? "none"),
                "user_id": .string(context.userId.map(String.init) ?? "none"),
            ]
        )
        try await next(context)
        self.logger.info("after route")
    }
}

/// Enforces a maximum duration for the downstream chain.
///
/// If the handler does not complete within `duration`, it throws
/// ``TelerouteTimeoutError`` and the downstream work is cancelled.
public struct TelerouteTimeoutMiddleware: TelerouteMiddleware {
    private let duration: Duration

    /// Creates a timeout middleware.
    public init(_ duration: Duration) {
        self.duration = duration
    }

    public func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) async throws {
        let result: Void = try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await next(context)
            }
            group.addTask {
                try await Task.sleep(for: self.duration)
                throw TelerouteTimeoutError(duration: self.duration)
            }
            // First child to finish wins. If the handler completes first, the
            // sleep task is cancelled on return. If the sleep fires first, the
            // handler task is cancelled by the group teardown.
            try await group.next()
            group.cancelAll()
        }
        return result
    }
}

/// Error thrown by ``TelerouteTimeoutMiddleware`` when the deadline elapses.
public struct TelerouteTimeoutError: Error, Equatable, Sendable {
    public let duration: Duration
    public init(duration: Duration) {
        self.duration = duration
    }
}

/// Retries the downstream chain when it throws, up to `retries` times.
///
/// The optional `backoff` closure is awaited between attempts and receives the
/// zero-based attempt index so callers can implement exponential backoff.
public struct TelerouteRetryMiddleware: TelerouteMiddleware {
    private let retries: Int
    private let backoff: @Sendable (Int) async -> Duration

    /// Creates a retry middleware.
    ///
    /// - Parameters:
    ///   - retries: Number of retry attempts after the initial try.
    ///   - backoff: Closure returning the delay before attempt `n` (0-based).
    public init(
        retries: Int,
        backoff: @escaping @Sendable (Int) async -> Duration = { _ in .milliseconds(0) }
    ) {
        self.retries = max(0, retries)
        self.backoff = backoff
    }

    public func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) async throws {
        var lastError: (any Error)?
        for attempt in 0...self.retries {
            do {
                try await next(context)
                return
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                lastError = error
            }
            if attempt < self.retries {
                let delay = await self.backoff(attempt)
                if delay > .zero {
                    try await Task.sleep(for: delay)
                }
            }
        }
        throw lastError ?? CancellationError()
    }
}

/// Catches errors thrown downstream and optionally converts them into a reply.
///
/// Pass `nil` for `reply` to swallow errors silently (useful when a group of
/// routes should never propagate failures to
/// ``TelerouteConfiguration/onError``).
public struct TelerouteErrorHandlingMiddleware: TelerouteMiddleware {
    private let handler: @Sendable (any Error, TelerouteContext) async -> Void

    /// Creates an error-handling middleware.
    public init(handler: @escaping @Sendable (any Error, TelerouteContext) async -> Void) {
        self.handler = handler
    }

    public func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) async throws {
        do {
            try await next(context)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            await self.handler(error, context)
        }
    }
}
