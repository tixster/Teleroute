import Foundation

/// A guard that passes only when every wrapped guard passes, evaluated in order.
///
/// Used internally to combine inherited and route-local guards.
struct TelerouteCompositeGuard: TelerouteGuard {
    let guards: [any TelerouteGuard]

    func matches(_ context: TelerouteContext) async throws -> Bool {
        for element in self.guards {
            if try await element.matches(context) == false {
                return false
            }
        }
        return true
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
        inheritedMiddlewares: [any TelerouteMiddleware],
        inheritedGuards: [any TelerouteGuard],
        guards: [any TelerouteGuard],
        middlewares: [any TelerouteMiddleware]
    ) -> [any TelerouteMiddleware] {
        return Self.resolve(
            guards: inheritedGuards + guards,
            middlewares: inheritedMiddlewares + middlewares
        )
    }
}
