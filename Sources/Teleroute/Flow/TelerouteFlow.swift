import SwiftTelegramBot
import Foundation

/// A stateful multi-step interaction mounted into `Teleroute`.
///
/// Flows keep one session per `chatId + userId` pair in the router's configured
/// `TelerouteFlowStorage` and can route messages, commands, and callback queries
/// based on the active step.
public protocol TelerouteFlow: Sendable {
    associatedtype Step: RawRepresentable & Hashable & Sendable where Step.RawValue == String

    /// Stable flow identifier stored in the session.
    static var id: String { get }

    /// Registers the flow's step handlers.
    func boot(flow: TelerouteFlowGroup<Self>)
}

public extension TelerouteFlow {
    static var id: String {
        String(reflecting: Self.self)
    }
}

/// Async handler invoked for a matched flow step.
public typealias TelerouteFlowHandler<Flow: TelerouteFlow> = @Sendable (
    _ update: TGUpdate,
    _ context: TelerouteFlowContext<Flow>
) async throws -> Void

/// Flow-specific registration API for step handlers.
public final class TelerouteFlowGroup<Flow: TelerouteFlow>: @unchecked Sendable {
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

    /// Registers a command that starts or restarts the flow at the supplied step.
    public func start(
        _ path: String,
        at step: Flow.Step,
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
                handler: { update, context in
                    try await context.start(Flow.self, at: step)
                    try await handler(update, context)
                }
            )
        )
    }

    /// Registers a handler for any non-callback message at the supplied step.
    public func message(
        at step: Flow.Step,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        use handler: @escaping TelerouteFlowHandler<Flow>
    ) {
        self.register(
            step: step,
            matcher: .message,
            routeGuard: routeGuard,
            middlewares: middlewares,
            handler: handler
        )
    }

    /// Registers a command handler for a specific step.
    public func command(
        _ path: String,
        at step: Flow.Step,
        botUsername: String? = nil,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        use handler: @escaping TelerouteFlowHandler<Flow>
    ) {
        self.register(
            step: step,
            matcher: .command(
                name: TeleroutePath.commandName(prefix: self.commandPrefix, path: path),
                botUsername: botUsername
            ),
            routeGuard: routeGuard,
            middlewares: middlewares,
            handler: handler
        )
    }

    /// Registers a callback handler for a specific step.
    public func callback(
        _ path: String,
        at step: Flow.Step,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        use handler: @escaping TelerouteFlowHandler<Flow>
    ) {
        self.register(
            step: step,
            matcher: .callback(.init(prefix: self.callbackPrefix, path: path)),
            routeGuard: routeGuard,
            middlewares: middlewares,
            handler: handler
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

    private func register(
        step: Flow.Step,
        matcher: TelerouteFlowRouteMatcher,
        routeGuard: (any TelerouteGuard)?,
        middlewares: [any TelerouteMiddleware],
        handler: @escaping TelerouteFlowHandler<Flow>
    ) {
        let resolvedMiddlewares = TelerouteMiddlewareComposer.resolve(
            routeGuard: routeGuard,
            middlewares: middlewares
        )
        self.storage.flowRoutes.append(
            .init(
                flowID: Flow.id,
                step: step.rawValue,
                matcher: matcher,
                middlewares: resolvedMiddlewares,
                handler: { update, context in
                    let flowContext = try TelerouteFlowContext<Flow>(context: context)
                    try await handler(update, flowContext)
                }
            )
        )
    }
}

/// Typed context passed to flow step handlers.
public struct TelerouteFlowContext<Flow: TelerouteFlow>: Sendable {
    /// Underlying router context.
    public let context: TelerouteContext
    /// Active flow session.
    public let session: TelerouteFlowSession
    /// Decoded current flow step.
    public let step: Flow.Step

    init(context: TelerouteContext) throws {
        guard let session = context.activeFlow else {
            throw TelerouteError.flowControllerMissing
        }
        guard session.id == Flow.id else {
            throw TelerouteError.invalidFlowStep(flowID: Flow.id, step: session.step)
        }
        guard let step = Flow.Step(rawValue: session.step) else {
            throw TelerouteError.invalidFlowStep(flowID: Flow.id, step: session.step)
        }
        self.context = context
        self.session = session
        self.step = step
    }

    /// Accumulated flow values for the active session.
    public var values: TelerouteFlowValues {
        self.session.values
    }

    /// Best-effort resolved Telegram message for the current update.
    public var message: TGMessage? {
        self.context.message
    }

    /// Current callback query, if any.
    public var callbackQuery: TGCallbackQuery? {
        self.context.callbackQuery
    }

    /// Raw callback data attached to the current callback query.
    public var callbackData: String? {
        self.context.callbackData
    }

    /// Parsed command metadata when the current step matched a command route.
    public var command: TelerouteCommandMatch? {
        self.context.command
    }

    /// Route parameters extracted from a callback pattern.
    public var parameters: TelerouteParameters {
        self.context.parameters
    }

    /// Bot instance associated with the router.
    public var bot: TGBot {
        self.context.bot
    }

    /// Target chat identifier inferred from the current update.
    public var chatId: Int64? {
        self.context.chatId
    }

    /// Best-effort resolved user identifier for the current update.
    public var userId: Int64? {
        self.context.userId
    }

    /// Replies to the current message when available, otherwise sends to the resolved chat.
    public func reply(
        text: String,
        parseMode: TGParseMode? = nil,
        replyMarkup: TGReplyMarkup? = nil
    ) async throws {
        try await self.context.reply(
            text: text,
            parseMode: parseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Sends a message to the supplied chat or to the chat inferred from the current update.
    public func send(
        text: String,
        to chatId: Int64? = nil,
        parseMode: TGParseMode? = nil,
        replyMarkup: TGReplyMarkup? = nil
    ) async throws {
        try await self.context.send(
            text: text,
            to: chatId,
            parseMode: parseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Edits the current message.
    public func edit(
        text: String,
        parseMode: TGParseMode? = nil,
        replyMarkup: TGInlineKeyboardMarkup? = nil
    ) async throws {
        try await self.context.edit(
            text: text,
            parseMode: parseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Answers the current callback query.
    public func answerCallbackQuery(
        text: String? = nil,
        showAlert: Bool? = nil,
        url: String? = nil,
        cacheTime: Int? = nil
    ) async throws {
        try await self.context.answerCallbackQuery(
            text: text,
            showAlert: showAlert,
            url: url,
            cacheTime: cacheTime
        )
    }

    /// Replaces the current flow session with a new step and values.
    public func restart(
        at step: Flow.Step,
        values: [String: String] = [:]
    ) async throws {
        try await self.context.start(Flow.self, at: step, values: values)
    }

    /// Moves the current flow to another step, merging new values into the session.
    public func transition(
        to step: Flow.Step,
        merging values: [String: String] = [:]
    ) async throws {
        let storage = try self.context.requireFlowStorage()
        let key = try self.context.requireFlowKey()
        await storage.setSession(
            .init(
                id: Flow.id,
                step: step.rawValue,
                values: self.session.values.merging(values)
            ),
            for: key
        )
    }

    /// Updates the current step values without changing the active step.
    public func update(
        merging values: [String: String]
    ) async throws {
        try await self.transition(to: self.step, merging: values)
    }

    /// Finishes the current flow session.
    public func finish() async throws {
        try await self.context.cancelFlow()
    }
}

public extension TelerouteGroup {
    /// Mounts a flow into the current route group.
    func add<Flow: TelerouteFlow>(flow: Flow) {
        flow.boot(
            flow: .init(
                storage: self.storage,
                commandPrefix: self.commandPrefix,
                callbackPrefix: self.callbackPrefix
            )
        )
    }
}

public extension Teleroute {
    /// Mounts a flow into the top-level router group.
    func add<Flow: TelerouteFlow>(flow: Flow) {
        self.rootGroup.add(flow: flow)
    }
}
