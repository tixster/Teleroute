import Foundation

/// A reusable feature that registers routes into a typed router scope.
///
/// Route collections may own dependencies and expose selected callback-route
/// handles to their parent without leaking callback paths across the project.
public protocol TelerouteRouteCollection: Sendable {
    associatedtype Context: TelerouteRequestContext
    associatedtype Exports: Sendable = Void

    /// Adds this feature's routes and returns its intentionally exported handles.
    func addRoutes(to routes: TelerouteRouterGroup<Context>) -> Exports
}

public extension TelerouteRouterGroup {
    /// Adds a reusable route collection to this scope.
    @discardableResult
    func addRoutes<Collection: TelerouteRouteCollection>(
        _ collection: Collection
    ) -> Collection.Exports where Collection.Context == Context {
        collection.addRoutes(to: self)
    }
}

/// A reusable controller-style feature that registers routes into any route scope.
///
/// Modules can store dependencies and expose their handlers as ordinary methods,
/// while callers only need to mount the module into the desired scope.
@_spi(Testing)
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

@_spi(Testing)
public extension TelerouteRuntime {
    /// Mounts a reusable route module at the router root.
    @discardableResult
    func mount<Module: TelerouteModule>(_ module: Module) -> Module.Exports {
        self.routeScope.mount(module)
    }
}
