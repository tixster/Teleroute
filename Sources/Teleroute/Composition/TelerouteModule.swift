import Foundation

/// A reusable controller-style feature that registers routes into any route scope.
///
/// Modules can store dependencies and expose their handlers as ordinary methods,
/// while callers only need to mount the module into the desired scope.
public protocol TelerouteModule: Sendable {
    /// Values made available to the module's parent after registration.
    associatedtype Exports: Sendable = Void

    /// Registers the feature and returns the route handles it intentionally exports.
    func register(in routes: TelerouteRoutes) -> Exports
}

public extension TelerouteRoutes {
    /// Mounts a reusable route module into this scope.
    @discardableResult
    func mount<Module: TelerouteModule>(_ module: Module) -> Module.Exports {
        module.register(in: self)
    }
}

public extension Teleroute {
    /// Mounts a reusable route module at the router root.
    @discardableResult
    func mount<Module: TelerouteModule>(_ module: Module) -> Module.Exports {
        self.routeScope.mount(module)
    }
}
