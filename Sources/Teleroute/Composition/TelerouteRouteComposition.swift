import Foundation

/// A guard combining wrapped guards in order: the first non-`allow` verdict
/// wins.
///
/// Used internally to combine inherited and route-local guards.
struct TelerouteCompositeGuard: TelerouteGuard {
    let guards: [any TelerouteGuard]

    func check(_ context: TelerouteContext) async throws -> TelerouteGuardResult {
        for element in self.guards {
            switch try await element.check(context) {
            case .allow:
                continue
            case .skip:
                return .skip
            case let .deny(response):
                return .deny(response)
            }
        }
        return .allow
    }
}

/// Helpers for composing middleware chains and guards inherited from a group.
extension TelerouteMiddlewareComposer {
    /// Resolves a route's middleware chain, prepending any group-inherited
    /// middleware and merging group-inherited guards with route-local guards.
    ///
    /// Group-inherited middleware runs before route middleware, and
    /// group-inherited guards are evaluated before route-local guards.
    static func resolve(
        inheritedMiddlewares: [any TelerouteMiddleware<TelerouteContext>],
        inheritedGuards: [any TelerouteGuard],
        guards: [any TelerouteGuard],
        middlewares: [any TelerouteMiddleware<TelerouteContext>]
    ) -> [any TelerouteMiddleware<TelerouteContext>] {
        return Self.resolve(
            guards: inheritedGuards + guards,
            middlewares: inheritedMiddlewares + middlewares
        )
    }
}
