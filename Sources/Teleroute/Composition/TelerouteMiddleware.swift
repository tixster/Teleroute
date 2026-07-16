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

protocol TelerouteConsumingMiddleware: TelerouteMiddleware {}

enum TelerouteMiddlewareComposer: Sendable {
    static func resolve(
        guards: [any TelerouteGuard],
        middlewares: [any TelerouteMiddleware]
    ) -> [any TelerouteMiddleware] {
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
        next: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) async throws {
        guard try await self.guardValue.matches(context) else { return }
        try await next(context)
    }
}
