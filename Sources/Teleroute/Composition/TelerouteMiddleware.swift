import Foundation

/// Route guard evaluated before a handler is invoked.
public protocol TelerouteGuard: Sendable {
    /// Returns `true` when the route should handle the current context.
    func matches(_ context: TelerouteContext) async throws -> Bool
}

/// Route middleware that can wrap handler execution.
public protocol TelerouteMiddleware: Sendable {
    /// Runs custom logic before and/or after the next handler in the chain.
    func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) async throws
}

enum TelerouteMiddlewareComposer: Sendable {
    static func resolve(
        routeGuard: (any TelerouteGuard)?,
        middlewares: [any TelerouteMiddleware]
    ) -> [any TelerouteMiddleware] {
        if let routeGuard {
            return [TelerouteGuardMiddleware(routeGuard: routeGuard)] + middlewares
        }
        return middlewares
    }
}

struct TelerouteGuardMiddleware: TelerouteMiddleware, Sendable {
    let routeGuard: any TelerouteGuard

    func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) async throws {
        guard try await self.routeGuard.matches(context) else { return }
        try await next(context)
    }
}
