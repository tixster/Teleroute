import SwiftTelegramBot
import Foundation

/// A route group with shared command and callback prefixes.
///
/// Group prefixes behave similarly to route groups:
/// commands are normalized using `_`, while callback routes keep `/`.
public final class TelerouteGroup: @unchecked Sendable {
    let storage: TelerouteStorage
    let commandPrefix: [String]
    let callbackPrefix: [String]

    init(
        storage: TelerouteStorage,
        commandPrefix: [String] = [],
        callbackPrefix: [String] = []
    ) {
        self.storage = storage
        self.commandPrefix = commandPrefix
        self.callbackPrefix = callbackPrefix
    }

    /// Creates a nested group inheriting the current prefixes.
    @discardableResult
    public func group(_ path: String) -> TelerouteGroup {
        let components = TeleroutePath.components(from: path)
        return .init(
            storage: self.storage,
            commandPrefix: self.commandPrefix + components,
            callbackPrefix: self.callbackPrefix + components
        )
    }

    /// Creates a nested group and configures it inline.
    public func group(_ path: String, configure: (TelerouteGroup) -> Void) {
        configure(self.group(path))
    }

    /// Registers a command handler.
    ///
    /// Example:
    /// `group("admin").command("ban")` matches `/admin_ban`.
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
        let name = TeleroutePath.commandName(prefix: self.commandPrefix, path: path)
        var resolvedMiddlewares = TelerouteMiddlewareComposer.resolve(
            routeGuard: routeGuard,
            middlewares: middlewares
        )
        if let queueing {
            let queueMiddleware = TelerouteCommandQueueMiddleware(
                queue: self.storage.commandQueue,
                routeName: name,
                queueing: queueing
            )
            let insertionIndex = routeGuard == nil ? 0 : 1
            resolvedMiddlewares.insert(queueMiddleware, at: insertionIndex)
        }
        if let description {
            for visibility in visibility {
                self.storage.publishedCommands.append(
                    .init(name: name, description: description, visibility: visibility)
                )
            }
        }
        self.storage.commandRoutes.append(
            .init(
                name: name,
                botUsername: botUsername,
                middlewares: resolvedMiddlewares,
                handler: handler
            )
        )
    }

    /// Registers a callback handler using a path-style pattern.
    ///
    /// Example:
    /// `callback("orders/{id}/approve")` matches callback data like `orders/42/approve`.
    public func callback(
        _ path: String,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        use handler: @escaping TelerouteHandler
    ) {
        let resolvedMiddlewares = TelerouteMiddlewareComposer.resolve(
            routeGuard: routeGuard,
            middlewares: middlewares
        )
        self.storage.callbackRoutes.append(
            .init(
                pattern: .init(prefix: self.callbackPrefix, path: path),
                middlewares: resolvedMiddlewares,
                handler: handler
            )
        )
    }

    /// Generates callback data from a path-style callback route and parameter values.
    public func callbackData(
        _ path: String,
        parameters: [String: String] = [:]
    ) throws -> String {
        try TelerouteCallbackPattern(prefix: self.callbackPrefix, path: path)
            .render(parameters: parameters)
    }

    /// Creates an inline keyboard button whose `callbackData` is derived from a callback route.
    public func callbackButton(
        _ text: String,
        path: String,
        parameters: [String: String] = [:],
        iconCustomEmojiId: String? = nil,
        style: String? = nil
    ) throws -> TGInlineKeyboardButton {
        TGInlineKeyboardButton(
            text: text,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style,
            callbackData: try self.callbackData(path, parameters: parameters)
        )
    }

    /// Creates multiple inline keyboard buttons from path-based callback routes.
    public func callbackButtons(
        _ items: [(text: String, path: String, parameters: [String: String])],
        iconCustomEmojiId: String? = nil,
        style: String? = nil
    ) throws -> [TGInlineKeyboardButton] {
        try items.map { item in
            try self.callbackButton(
                item.text,
                path: item.path,
                parameters: item.parameters,
                iconCustomEmojiId: iconCustomEmojiId,
                style: style
            )
        }
    }

    /// Builds an inline keyboard from rows of buttons.
    public func callbackKeyboard(
        _ rows: [[TGInlineKeyboardButton]]
    ) -> TGInlineKeyboardMarkup {
        TGInlineKeyboardMarkup(inlineKeyboard: rows)
    }
}
