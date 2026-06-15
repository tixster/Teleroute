import Foundation

/// A guard that passes only when every wrapped guard passes, evaluated in order.
///
/// Used internally to combine group-inherited guards with the per-route guard.
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
    /// middleware and merging group-inherited guards with the route guard.
    ///
    /// Group-inherited middleware runs before route middleware, and
    /// group-inherited guards are evaluated before the route guard. When both
    /// inherited and route guards are present they are combined into a
    /// ``TelerouteCompositeGuard`` so the route sees a single guard that
    /// short-circuits on the first failure.
    static func resolve(
        inheritedMiddlewares: [any TelerouteMiddleware],
        inheritedGuards: [any TelerouteGuard],
        routeGuard: (any TelerouteGuard)?,
        middlewares: [any TelerouteMiddleware]
    ) -> [any TelerouteMiddleware] {
        let combinedGuard: (any TelerouteGuard)?
        if inheritedGuards.isEmpty {
            combinedGuard = routeGuard
        } else if let routeGuard {
            combinedGuard = TelerouteCompositeGuard(guards: inheritedGuards + [routeGuard])
        } else {
            combinedGuard = TelerouteCompositeGuard(guards: inheritedGuards)
        }
        return Self.resolve(
            routeGuard: combinedGuard,
            middlewares: inheritedMiddlewares + middlewares
        )
    }
}
