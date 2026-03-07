import Foundation
import SwiftTelegramBot

/// A reusable bundle of routes that can be mounted into any `TelerouteGroup`.
public protocol TelerouteCollection: Sendable {
    /// Registers the collection's routes into the supplied route group.
    func boot(routes: TelerouteGroup)
}

/// A `TelerouteCollection` variant that boots through a collection-scoped route builder.
public protocol TelerouteCollectionBuilder: TelerouteCollection {
    /// Registers the collection's routes into the supplied collection-scoped route builder.
    func boot(collection: TelerouteCollectionGroup)
}

/// A collection that defines and owns its own route group path.
///
/// This allows mounting a collection directly via `router.group(AdminRoutes())`
/// without spelling the path outside the collection type.
public protocol TelerouteGroupCollection: TelerouteCollectionBuilder {
    /// Group path relative to the current router/group.
    var path: String { get }
}

/// Collection-scoped route builder.
///
/// This mirrors `TelerouteGroup`, but lets collections stay self-contained without
/// exposing the raw router type in their public API.
public struct TelerouteCollectionGroup: Sendable {
    let group: TelerouteGroup

    init(group: TelerouteGroup) {
        self.group = group
    }

    /// Underlying raw route group.
    public var routes: TelerouteGroup {
        self.group
    }

    /// Creates a nested group inheriting the current prefixes.
    public func group(_ path: String) -> TelerouteCollectionGroup {
        .init(group: self.group.group(path))
    }

    /// Creates a nested group and configures it inline.
    public func group(
        _ path: String,
        configure: (TelerouteCollectionGroup) -> Void
    ) {
        configure(self.group(path))
    }

    /// Registers a command handler.
    public func command(
        _ path: String,
        botUsername: String? = nil,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility] = [.default],
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        queueing: TelerouteCommandQueueing? = nil,
        use handler: @escaping TelerouteHandler
    ) {
        self.group.command(
            path,
            botUsername: botUsername,
            description: description,
            visibility: visibility,
            routeGuard: routeGuard,
            middlewares: middlewares,
            queueing: queueing,
            use: handler
        )
    }

    /// Registers a callback handler using a path-style pattern.
    public func callback(
        _ path: String,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        use handler: @escaping TelerouteHandler
    ) {
        self.group.callback(
            path,
            routeGuard: routeGuard,
            middlewares: middlewares,
            use: handler
        )
    }

    /// Generates callback data from a path-style callback route and parameter values.
    public func callbackData(
        _ path: String,
        parameters: [String: String] = [:]
    ) throws -> String {
        try self.group.callbackData(path, parameters: parameters)
    }

    /// Creates an inline keyboard button whose `callbackData` is derived from a callback route.
    public func callbackButton(
        _ text: String,
        path: String,
        parameters: [String: String] = [:],
        iconCustomEmojiId: String? = nil,
        style: String? = nil
    ) throws -> TGInlineKeyboardButton {
        try self.group.callbackButton(
            text,
            path: path,
            parameters: parameters,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style
        )
    }

    /// Creates multiple inline keyboard buttons from path-based callback routes.
    public func callbackButtons(
        _ items: [(text: String, path: String, parameters: [String: String])],
        iconCustomEmojiId: String? = nil,
        style: String? = nil
    ) throws -> [TGInlineKeyboardButton] {
        try self.group.callbackButtons(
            items,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style
        )
    }

    /// Builds an inline keyboard from rows of buttons.
    public func callbackKeyboard(
        _ rows: [[TGInlineKeyboardButton]]
    ) -> TGInlineKeyboardMarkup {
        self.group.callbackKeyboard(rows)
    }

    /// Mounts a nested collection into the current group.
    public func add<NestedCollection: TelerouteCollection>(collection: NestedCollection) {
        self.group.add(collection: collection)
    }

    /// Mounts a flow into the current group.
    public func add<Flow: TelerouteFlow>(flow: Flow) {
        self.group.add(flow: flow)
    }
}

public extension TelerouteGroup {
    /// Mounts a route collection into the current group.
    func add<Collection: TelerouteCollection>(collection: Collection) {
        let collectionGroup = TelerouteCollectionGroup(group: self)
        if let builder = collection as? any TelerouteCollectionBuilder {
            builder.boot(collection: collectionGroup)
            return
        }
        collection.boot(routes: self)
    }

    /// Creates a nested group from a collection-defined path and mounts the collection into it.
    @discardableResult
    func group<Collection: TelerouteGroupCollection>(_ collection: Collection) -> TelerouteGroup {
        let grouped = self.group(collection.path)
        grouped.add(collection: collection)
        return grouped
    }
}

public extension Teleroute {
    /// Mounts a route collection into the top-level router group.
    func add<Collection: TelerouteCollection>(collection: Collection) {
        let collectionGroup = TelerouteCollectionGroup(group: self.rootGroup)
        if let builder = collection as? any TelerouteCollectionBuilder {
            builder.boot(collection: collectionGroup)
            return
        }
        collection.boot(routes: self.rootGroup)
    }

    /// Creates a top-level group from a collection-defined path and mounts the collection into it.
    @discardableResult
    func group<Collection: TelerouteGroupCollection>(_ collection: Collection) -> TelerouteGroup {
        self.rootGroup.group(collection)
    }
}

public extension TelerouteCollectionBuilder {
    /// Registers the collection's routes into the supplied raw route group.
    func boot(routes: TelerouteGroup) {
        self.boot(collection: .init(group: routes))
    }
}
