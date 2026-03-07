import SwiftTelegramBot
import Foundation

public extension TelerouteGroup {
    /// Registers a typed command whose handler lives on the command value itself.
    func command<Command: TelerouteCommand>(
        _ commandType: Command.Type,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility]? = nil,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        queueing: TelerouteCommandQueueing? = nil,
    ) {
        self.command(
            Command.path,
            botUsername: Command.botUsername,
            description: description ?? Command.commandDescription,
            visibility: visibility ?? Command.visibility,
            routeGuard: routeGuard,
            middlewares: middlewares,
            queueing: queueing ?? Command.queueing
        ) { update, context in
            let command = try Command(
                command: context.command
                    ?? TelerouteCommandMatch(
                        name: Command.path,
                        rawValue: "/\(Command.path)",
                        mentionedBotUsername: nil,
                        argumentsText: nil,
                        arguments: []
                    )
            )
            try await command.handle(update: update, context: context)
        }
    }

    /// Registers a typed command handler.
    func command<Command: TelerouteCommand>(
        _ commandType: Command.Type,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility]? = nil,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        queueing: TelerouteCommandQueueing? = nil,
        use handler: @escaping @Sendable (_ update: TGUpdate, _ context: TelerouteContext, _ command: Command) async throws -> Void
    ) {
        self.command(
            Command.path,
            botUsername: Command.botUsername,
            description: description ?? Command.commandDescription,
            visibility: visibility ?? Command.visibility,
            routeGuard: routeGuard,
            middlewares: middlewares,
            queueing: queueing ?? Command.queueing
        ) { update, context in
            try await handler(update, context, Command(command: context.command ?? TelerouteCommandMatch(name: Command.path, rawValue: "/\(Command.path)", mentionedBotUsername: nil, argumentsText: nil, arguments: [])))
        }
    }

    /// Generates callback data for a typed callback value.
    func callbackData<Callback: TelerouteCallback>(for callback: Callback) throws -> String {
        try self.callbackData(Callback.path, parameters: callback.parameters)
    }

    /// Generates callback data for an existential typed callback value.
    func callbackData(for callback: any TelerouteCallback) throws -> String {
        try self.callbackData(type(of: callback).path, parameters: callback.parameters)
    }

    /// Creates an inline keyboard button for a typed callback value.
    func callbackButton<Callback: TelerouteCallback>(
        _ text: String,
        callback: Callback,
        iconCustomEmojiId: String? = nil,
        style: String? = nil
    ) throws -> TGInlineKeyboardButton {
        .init(
            text: text,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style,
            callbackData: try self.callbackData(for: callback)
        )
    }

    /// Creates an inline keyboard button for an existential typed callback value.
    func callbackButton(
        _ text: String,
        callback: any TelerouteCallback,
        iconCustomEmojiId: String? = nil,
        style: String? = nil
    ) throws -> TGInlineKeyboardButton {
        .init(
            text: text,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style,
            callbackData: try self.callbackData(for: callback)
        )
    }

    /// Creates multiple inline keyboard buttons from typed callback values.
    func callbackButtons<Callback: TelerouteCallback>(
        _ items: [(text: String, callback: Callback)],
        iconCustomEmojiId: String? = nil,
        style: String? = nil
    ) throws -> [TGInlineKeyboardButton] {
        try items.map { item in
            try self.callbackButton(
                item.text,
                callback: item.callback,
                iconCustomEmojiId: iconCustomEmojiId,
                style: style
            )
        }
    }

    /// Creates multiple inline keyboard buttons from heterogeneous typed callback values.
    func callbackButtons(
        _ items: [(text: String, callback: any TelerouteCallback)],
        iconCustomEmojiId: String? = nil,
        style: String? = nil
    ) throws -> [TGInlineKeyboardButton] {
        try items.map { item in
            try self.callbackButton(
                item.text,
                callback: item.callback,
                iconCustomEmojiId: iconCustomEmojiId,
                style: style
            )
        }
    }

    /// Registers a typed callback handler.
    func callback<Callback: TelerouteCallback>(
        _ callbackType: Callback.Type,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
    ) {
        self.callback(Callback.path, routeGuard: routeGuard, middlewares: middlewares) { update, context in
            let callback = try Callback(parameters: context.parameters)
            try await callback.handle(update: update, context: context)
        }
    }

    /// Registers a typed callback handler.
    func callback<Callback: TelerouteCallback>(
        _ callbackType: Callback.Type,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        use handler: @escaping @Sendable (_ update: TGUpdate, _ context: TelerouteContext, _ callback: Callback) async throws -> Void
    ) {
        self.callback(Callback.path, routeGuard: routeGuard, middlewares: middlewares) { update, context in
            try await handler(update, context, Callback(parameters: context.parameters))
        }
    }
}

public extension TelerouteCollectionGroup {
    /// Registers a typed command whose handler lives on the command value itself.
    func command<Command: TelerouteCommand>(
        _ commandType: Command.Type,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility]? = nil,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        queueing: TelerouteCommandQueueing? = nil,
    ) {
        self.group.command(
            commandType,
            description: description,
            visibility: visibility,
            routeGuard: routeGuard,
            middlewares: middlewares,
            queueing: queueing
        )
    }

    /// Registers a typed command handler.
    func command<Command: TelerouteCommand>(
        _ commandType: Command.Type,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility]? = nil,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        queueing: TelerouteCommandQueueing? = nil,
        use handler: @escaping @Sendable (_ update: TGUpdate, _ context: TelerouteContext, _ command: Command) async throws -> Void
    ) {
        self.group.command(
            commandType,
            description: description,
            visibility: visibility,
            routeGuard: routeGuard,
            middlewares: middlewares,
            queueing: queueing,
            use: handler
        )
    }

    /// Generates callback data for a typed callback value.
    func callbackData<Callback: TelerouteCallback>(for callback: Callback) throws -> String {
        try self.group.callbackData(for: callback)
    }

    /// Generates callback data for an existential typed callback value.
    func callbackData(for callback: any TelerouteCallback) throws -> String {
        try self.group.callbackData(for: callback)
    }

    /// Creates an inline keyboard button for a typed callback value.
    func callbackButton<Callback: TelerouteCallback>(
        _ text: String,
        callback: Callback,
        iconCustomEmojiId: String? = nil,
        style: String? = nil
    ) throws -> TGInlineKeyboardButton {
        try self.group.callbackButton(
            text,
            callback: callback,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style
        )
    }

    /// Creates an inline keyboard button for an existential typed callback value.
    func callbackButton(
        _ text: String,
        callback: any TelerouteCallback,
        iconCustomEmojiId: String? = nil,
        style: String? = nil
    ) throws -> TGInlineKeyboardButton {
        try self.group.callbackButton(
            text,
            callback: callback,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style
        )
    }

    /// Creates multiple inline keyboard buttons from typed callback values.
    func callbackButtons<Callback: TelerouteCallback>(
        _ items: [(text: String, callback: Callback)],
        iconCustomEmojiId: String? = nil,
        style: String? = nil
    ) throws -> [TGInlineKeyboardButton] {
        try self.group.callbackButtons(
            items,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style
        )
    }

    /// Creates multiple inline keyboard buttons from heterogeneous typed callback values.
    func callbackButtons(
        _ items: [(text: String, callback: any TelerouteCallback)],
        iconCustomEmojiId: String? = nil,
        style: String? = nil
    ) throws -> [TGInlineKeyboardButton] {
        try self.group.callbackButtons(
            items,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style
        )
    }

    /// Registers a typed callback handler whose handler lives on the callback value itself.
    func callback<Callback: TelerouteCallback>(
        _ callbackType: Callback.Type,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
    ) {
        self.group.callback(
            callbackType,
            routeGuard: routeGuard,
            middlewares: middlewares
        )
    }

    /// Registers a typed callback handler.
    func callback<Callback: TelerouteCallback>(
        _ callbackType: Callback.Type,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        use handler: @escaping @Sendable (_ update: TGUpdate, _ context: TelerouteContext, _ callback: Callback) async throws -> Void
    ) {
        self.group.callback(
            callbackType,
            routeGuard: routeGuard,
            middlewares: middlewares,
            use: handler
        )
    }
}

public extension Teleroute {
    /// Registers a typed command whose handler lives on the command value itself.
    func command<Command: TelerouteCommand>(
        _ commandType: Command.Type,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility]? = nil,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        queueing: TelerouteCommandQueueing? = nil,
    ) {
        self.rootGroup.command(
            commandType,
            description: description,
            visibility: visibility,
            routeGuard: routeGuard,
            middlewares: middlewares,
            queueing: queueing
        )
    }

    /// Registers a typed command handler.
    func command<Command: TelerouteCommand>(
        _ commandType: Command.Type,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility]? = nil,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        queueing: TelerouteCommandQueueing? = nil,
        use handler: @escaping @Sendable (_ update: TGUpdate, _ context: TelerouteContext, _ command: Command) async throws -> Void
    ) {
        self.rootGroup.command(
            commandType,
            description: description,
            visibility: visibility,
            routeGuard: routeGuard,
            middlewares: middlewares,
            queueing: queueing,
            use: handler
        )
    }

    /// Registers a typed callback handler.
    func callback<Callback: TelerouteCallback>(
        _ callbackType: Callback.Type,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
    ) {
        self.rootGroup.callback(
            callbackType,
            routeGuard: routeGuard,
            middlewares: middlewares
        )
    }

    /// Registers a typed callback handler.
    func callback<Callback: TelerouteCallback>(
        _ callbackType: Callback.Type,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        use handler: @escaping @Sendable (_ update: TGUpdate, _ context: TelerouteContext, _ callback: Callback) async throws -> Void
    ) {
        self.rootGroup.callback(callbackType, routeGuard: routeGuard, middlewares: middlewares, use: handler)
    }

    /// Generates callback data for a typed callback value.
    func callbackData<Callback: TelerouteCallback>(for callback: Callback) throws -> String {
        try self.rootGroup.callbackData(for: callback)
    }

    /// Generates callback data for an existential typed callback value.
    func callbackData(for callback: any TelerouteCallback) throws -> String {
        try self.rootGroup.callbackData(for: callback)
    }

    /// Creates an inline keyboard button for a typed callback value.
    func callbackButton<Callback: TelerouteCallback>(
        _ text: String,
        callback: Callback,
        iconCustomEmojiId: String? = nil,
        style: String? = nil
    ) throws -> TGInlineKeyboardButton {
        try self.rootGroup.callbackButton(
            text,
            callback: callback,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style
        )
    }

    /// Creates an inline keyboard button for an existential typed callback value.
    func callbackButton(
        _ text: String,
        callback: any TelerouteCallback,
        iconCustomEmojiId: String? = nil,
        style: String? = nil
    ) throws -> TGInlineKeyboardButton {
        try self.rootGroup.callbackButton(
            text,
            callback: callback,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style
        )
    }

    /// Creates multiple inline keyboard buttons from typed callback values.
    func callbackButtons<Callback: TelerouteCallback>(
        _ items: [(text: String, callback: Callback)],
        iconCustomEmojiId: String? = nil,
        style: String? = nil
    ) throws -> [TGInlineKeyboardButton] {
        try self.rootGroup.callbackButtons(
            items,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style
        )
    }

    /// Creates multiple inline keyboard buttons from heterogeneous typed callback values.
    func callbackButtons(
        _ items: [(text: String, callback: any TelerouteCallback)],
        iconCustomEmojiId: String? = nil,
        style: String? = nil
    ) throws -> [TGInlineKeyboardButton] {
        try self.rootGroup.callbackButtons(
            items,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style
        )
    }

}
