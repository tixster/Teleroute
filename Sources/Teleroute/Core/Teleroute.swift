@_exported import Foundation
@_exported import Logging
@_exported import SwiftTelegramBot

/// Router for `swift-telegram-bot`.
///
/// `Teleroute` is a `TGDefaultDispatcher` subclass, so it can be attached directly
/// to `TGBot` and process incoming updates through the existing dispatcher pipeline.
public final class Teleroute: TGDefaultDispatcher, @unchecked Sendable {
    let storage = TelerouteStorage()
    private let flowStorage: any TelerouteFlowStorage
    private let replayProtectionStorage: (any TelerouteReplayProtectionStorage)?
    private let replayProtectionTTL: Duration
    private var hasRegisteredHandlers = false
    lazy var rootGroup = TelerouteGroup(storage: self.storage)

    /// Creates a router bound to a Telegram bot and logger.
    public override init(bot: TGBot, logger: Logger) {
        self.flowStorage = TelerouteInMemoryFlowStorage()
        self.replayProtectionStorage = TelerouteInMemoryReplayProtectionStorage()
        self.replayProtectionTTL = .seconds(2)
        super.init(bot: bot, logger: logger)
    }

    /// Creates a router bound to a Telegram bot, logger, and custom flow storage.
    public init(
        bot: TGBot,
        logger: Logger,
        flowStorage: any TelerouteFlowStorage,
        replayProtectionStorage: (any TelerouteReplayProtectionStorage)? = TelerouteInMemoryReplayProtectionStorage(),
        replayProtectionTTL: Duration = .seconds(2)
    ) {
        self.flowStorage = flowStorage
        self.replayProtectionStorage = replayProtectionStorage
        self.replayProtectionTTL = replayProtectionTTL
        super.init(bot: bot, logger: logger)
    }

    /// Creates a top-level route group.
    @discardableResult
    public func group(_ path: String) -> TelerouteGroup {
        self.rootGroup.group(path)
    }

    /// Creates and configures a top-level route group inline.
    public func group(_ path: String, configure: (TelerouteGroup) -> Void) {
        self.rootGroup.group(path, configure: configure)
    }

    /// Registers a top-level command handler.
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
        self.rootGroup.command(
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

    /// Registers a top-level callback handler.
    public func callback(
        _ path: String,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        use handler: @escaping TelerouteHandler
    ) {
        self.rootGroup.callback(
            path,
            routeGuard: routeGuard,
            middlewares: middlewares,
            use: handler
        )
    }

    /// Generates callback data for a top-level callback route.
    public func callbackData(
        _ path: String,
        parameters: [String: String] = [:]
    ) throws -> String {
        try self.rootGroup.callbackData(path, parameters: parameters)
    }

    /// Creates an inline keyboard button for a top-level callback route.
    public func callbackButton(
        _ text: String,
        path: String,
        parameters: [String: String] = [:],
        iconCustomEmojiId: String? = nil,
        style: String? = nil
    ) throws -> TGInlineKeyboardButton {
        try self.rootGroup.callbackButton(
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
        try self.rootGroup.callbackButtons(
            items,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style
        )
    }

    /// Builds an inline keyboard from rows of buttons.
    public func callbackKeyboard(
        _ rows: [[TGInlineKeyboardButton]]
    ) -> TGInlineKeyboardMarkup {
        self.rootGroup.callbackKeyboard(rows)
    }

    /// `TGDefaultDispatcher` entry point. Registers internal Telegram handlers once.
    public override func handle() async {
        guard !self.hasRegisteredHandlers else { return }
        self.hasRegisteredHandlers = true

        await self.add(
            TGBaseHandler(name: "TelerouteDispatcher") { [weak self] update in
                guard let self else { return }
                do {
                    self.log.debug("Received update", metadata: self.updateMetadata(for: update))
                    guard await self.shouldHandle(update) else {
                        self.log.debug("Skipped duplicate update", metadata: self.updateMetadata(for: update))
                        return
                    }
                    if try await self.processFlow(update) {
                        self.log.debug("Handled update with flow route", metadata: self.updateMetadata(for: update))
                        return
                    }
                    if try await self.processCallback(update) {
                        self.log.debug("Handled update with callback route", metadata: self.updateMetadata(for: update))
                        return
                    }
                    if try await self.processCommand(update) {
                        self.log.debug("Handled update with command route", metadata: self.updateMetadata(for: update))
                        return
                    }
                    self.log.debug("No route matched update", metadata: self.updateMetadata(for: update))
                } catch {
                    await self.logProcessingError(error, update: update)
                }
            }
        )
    }

    private func updateMetadata(for update: TGUpdate) -> Logger.Metadata {
        let context = TelerouteContext(bot: self.bot, update: update)
        var metadata: Logger.Metadata = [
            "update_id": .stringConvertible(update.updateId),
            "chat_id": .string(context.chatId.map(String.init) ?? "none"),
            "user_id": .string(context.userId.map(String.init) ?? "none"),
        ]

        if let command = TelerouteCommandExtractor.extract(from: update) {
            metadata["route_kind"] = .string("command")
            metadata["command"] = .string(command.name)
        } else if let callbackData = update.callbackQuery?.data {
            metadata["route_kind"] = .string("callback")
            metadata["callback_data"] = .string(callbackData)
        } else if let text = context.message?.text, text.isEmpty == false {
            metadata["route_kind"] = .string("message")
            metadata["message_text"] = .string(text)
        } else {
            metadata["route_kind"] = .string("unknown")
        }

        return metadata
    }

    private func logProcessingError(_ error: any Error, update: TGUpdate) async {
        let context = TelerouteContext(bot: self.bot, update: update)
        var metadata = self.updateMetadata(for: update)
        metadata.merge([
            "error_type": .string(String(reflecting: type(of: error))),
        ]) { _, new in new }

        if let command = TelerouteCommandExtractor.extract(from: update),
           let argumentsText = command.argumentsText,
           argumentsText.isEmpty == false {
            metadata["command_arguments"] = .string(argumentsText)
        }

        if let flowKey = context.flowKey,
           let session = await self.flowStorage.session(for: flowKey) {
            metadata["flow_id"] = .string(session.id)
            metadata["flow_step"] = .string(session.step)
        }

        self.log.error(Self.errorMessage(for: error), metadata: metadata)
    }

    private static func errorMessage(for error: any Error) -> Logger.Message {
        if let botError = error as? BotError {
            return .init(stringLiteral: botError.localizedDescription)
        }

        if let localizedError = error as? any LocalizedError,
           let description = localizedError.errorDescription,
           description.isEmpty == false {
            return .init(stringLiteral: description)
        }

        let fallback = error.localizedDescription == error._domain
            ? String(reflecting: error)
            : error.localizedDescription
        return .init(stringLiteral: fallback)
    }

    private func shouldHandle(_ update: TGUpdate) async -> Bool {
        guard let replayProtectionStorage = self.replayProtectionStorage,
              let key = self.replayProtectionKey(for: update) else {
            return true
        }
        return await replayProtectionStorage.claim(key: key, ttl: self.replayProtectionTTL)
    }

    private func replayProtectionKey(for update: TGUpdate) -> String? {
        let context = TelerouteContext(bot: self.bot, update: update)
        let chatID = context.chatId.map(String.init) ?? "none"
        let userID = context.userId.map(String.init) ?? "none"

        if let callbackData = update.callbackQuery?.data {
            return "callback|\(chatID)|\(userID)|\(callbackData)"
        }

        if let command = TelerouteCommandExtractor.extract(from: update) {
            return "command|\(chatID)|\(userID)|\(command.name)|\(command.argumentsText ?? "")"
        }

        return nil
    }

    @discardableResult
    private func processFlow(_ update: TGUpdate) async throws -> Bool {
        let baseContext = TelerouteContext(
            bot: self.bot,
            update: update,
            flowStorage: self.flowStorage,
            flowSession: nil
        )
        guard let flowKey = baseContext.flowKey,
              let session = await self.flowStorage.session(for: flowKey) else {
            return false
        }

        if let callbackData = update.callbackQuery?.data {
            for route in self.storage.flowRoutes {
                guard route.flowID == session.id, route.step == session.step else {
                    continue
                }
                guard case let .callback(pattern) = route.matcher,
                      let parameters = pattern.match(callbackData) else {
                    continue
                }
                let context = TelerouteContext(
                    bot: self.bot,
                    update: update,
                    parameters: parameters,
                    flowStorage: self.flowStorage,
                    flowSession: session
                )
                let handled = try await Self.run(
                    middlewares: route.middlewares,
                    context: context,
                    update: update,
                    handler: route.handler
                )
                if handled {
                    return true
                }
            }
            return false
        }

        if TelerouteCommandExtractor.extract(from: update) != nil {
            await self.flowStorage.removeSession(for: flowKey)
            return false
        }

        guard TelerouteMessageExtractor.extract(from: update) != nil else {
            return false
        }

        for route in self.storage.flowRoutes {
            guard route.flowID == session.id, route.step == session.step else {
                continue
            }
            guard case .message = route.matcher else {
                continue
            }
            let context = TelerouteContext(
                bot: self.bot,
                update: update,
                parameters: .init(),
                command: nil,
                flowStorage: self.flowStorage,
                flowSession: session
            )
            let handled = try await Self.run(
                middlewares: route.middlewares,
                context: context,
                update: update,
                handler: route.handler
            )
            if handled {
                return true
            }
        }

        return false
    }

    @discardableResult
    private func processCommand(_ update: TGUpdate) async throws -> Bool {
        guard let command = TelerouteCommandExtractor.extract(from: update) else {
            return false
        }
        for route in self.storage.commandRoutes where {
            guard $0.name == command.name else { return false }
            guard let expectedUsername = $0.botUsername,
                  let mentionedUsername = command.mentionedBotUsername else {
                return $0.name == command.name
            }
            return expectedUsername == mentionedUsername
        }(route) {
            let context = TelerouteContext(
                bot: self.bot,
                update: update,
                parameters: .init(),
                command: command,
                flowStorage: self.flowStorage,
                flowSession: nil
            )
            let handled = try await Self.run(
                middlewares: route.middlewares,
                context: context,
                update: update,
                handler: route.handler
            )
            if handled == false {
                continue
            }
            return true
        }
        return false
    }

    @discardableResult
    private func processCallback(_ update: TGUpdate) async throws -> Bool {
        guard let data = update.callbackQuery?.data else {
            return false
        }
        for route in self.storage.callbackRoutes {
            guard let parameters = route.pattern.match(data) else {
                continue
            }
            let context = TelerouteContext(
                bot: self.bot,
                update: update,
                parameters: parameters,
                command: nil,
                flowStorage: self.flowStorage,
                flowSession: nil
            )
            let handled = try await Self.run(
                middlewares: route.middlewares,
                context: context,
                update: update,
                handler: route.handler
            )
            if handled == false {
                continue
            }
            return true
        }
        return false
    }

    private static func run(
        middlewares: [any TelerouteMiddleware],
        context: TelerouteContext,
        update: TGUpdate,
        handler: @escaping TelerouteHandler
    ) async throws -> Bool {
        let runner = TelerouteMiddlewareRunner(
            middlewares: middlewares,
            update: update,
            handler: handler
        )
        return try await runner.run(context: context)
    }
}
