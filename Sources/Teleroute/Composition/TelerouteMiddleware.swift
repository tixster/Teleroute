import Foundation

/// Verdict of a route guard.
public enum TelerouteGuardResult: Sendable {
    /// The route may handle the update.
    case allow
    /// The route silently skips the update; matching continues with the next
    /// candidate route.
    case skip
    /// The route consumes the update and responds with the supplied action
    /// (for example, an "access denied" reply).
    case deny(TelerouteResponse)
}

/// Route guard evaluated before a handler is invoked.
public protocol TelerouteGuard: Sendable {
    /// Decides whether the route should handle the current context.
    func check(_ context: TelerouteContext) async throws -> TelerouteGuardResult
}

/// Route middleware wrapping handler execution for a request context type.
///
/// One protocol serves both levels: middleware over ``TelerouteContext`` can
/// be attached to any route or group (`middlewares:` parameters), and
/// middleware over a custom context is added through a group's
/// ``TelerouteRouterGroup/middlewares`` collection.
public protocol TelerouteMiddleware<Context>: Sendable {
    associatedtype Context: TelerouteRequestContext

    /// Runs custom logic around the next step in the chain and returns the
    /// route's response (its own, or the one produced downstream).
    func handle(
        _ context: Context,
        next: @escaping @Sendable (Context) async throws -> TelerouteResponse
    ) async throws -> TelerouteResponse
}

/// Error that aborts a route and renders the carried response to the user.
public struct TelerouteAbort: Error, Sendable {
    public let response: TelerouteResponse

    public init(_ response: TelerouteResponse) {
        self.response = response
    }

    /// Aborts with a plain-text reply.
    public init(_ text: String) {
        self.response = .reply(Reply(text))
    }
}

enum TelerouteMiddlewareComposer: Sendable {
    static func resolve(
        guards: [any TelerouteGuard],
        middlewares: [any TelerouteMiddleware<TelerouteContext>]
    ) -> [any TelerouteMiddleware<TelerouteContext>] {
        guard guards.isEmpty == false else { return middlewares }
        let combinedGuard: any TelerouteGuard = guards.count == 1
            ? guards[0]
            : TelerouteCompositeGuard(guards: guards)
        return [TelerouteGuardMiddleware(guardValue: combinedGuard)] + middlewares
    }
}

struct TelerouteGuardMiddleware: TelerouteMiddleware, Sendable {
    let guardValue: any TelerouteGuard

    func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> TelerouteResponse
    ) async throws -> TelerouteResponse {
        switch try await self.guardValue.check(context) {
        case .allow:
            return try await next(context)
        case .skip:
            return .unhandled
        case let .deny(response):
            return response
        }
    }
}
