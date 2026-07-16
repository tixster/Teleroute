import Foundation

/// A reusable controller-style feature that registers routes into any route scope.
///
/// Modules can store dependencies and expose their handlers as ordinary methods,
/// while callers only need to mount the module into the desired scope.
public protocol TelerouteModule: Sendable {
    func register(in routes: TelerouteRoutes)
}

public extension TelerouteRoutes {
    /// Mounts a reusable route module into this scope.
    func mount<Module: TelerouteModule>(_ module: Module) {
        module.register(in: self)
    }
}

public extension Teleroute {
    /// Mounts a reusable route module at the router root.
    func mount<Module: TelerouteModule>(_ module: Module) {
        self.routeScope.mount(module)
    }
}
