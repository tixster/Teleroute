import Foundation
import SwiftTelegramBot

/// Async route handler invoked for matched commands and callback queries.
///
/// - Parameters:
///   - update: Raw Telegram update received from `swift-telegram-bot`.
///   - context: Router context containing extracted parameters and convenience helpers.
public typealias TelerouteHandler = @Sendable (_ update: TGUpdate, _ context: TelerouteContext) async throws -> Void

/// Context passed to router handlers.
///
/// It exposes the matched command, callback data, decoded route parameters,
/// and a set of helpers for replying through `swift-telegram-bot`.
public struct TelerouteContext: Sendable {
    /// Bot instance associated with the router.
    public let bot: TGBot
    /// Raw Telegram update currently being processed.
    public let update: TGUpdate
    /// Route parameters extracted from a callback pattern.
    public let parameters: TelerouteParameters
    /// Parsed command metadata when the handler was invoked by a command route.
    public let command: TelerouteCommandMatch?
    let flowStorage: (any TelerouteFlowStorage)?
    let flowSession: TelerouteFlowSession?

    /// Creates a context for a matched route.
    public init(
        bot: TGBot,
        update: TGUpdate,
        parameters: TelerouteParameters = .init(),
        command: TelerouteCommandMatch? = nil
    ) {
        self.bot = bot
        self.update = update
        self.parameters = parameters
        self.command = command
        self.flowStorage = nil
        self.flowSession = nil
    }

    init(
        bot: TGBot,
        update: TGUpdate,
        parameters: TelerouteParameters = .init(),
        command: TelerouteCommandMatch? = nil,
        flowStorage: (any TelerouteFlowStorage)?,
        flowSession: TelerouteFlowSession?
    ) {
        self.bot = bot
        self.update = update
        self.parameters = parameters
        self.command = command
        self.flowStorage = flowStorage
        self.flowSession = flowSession
    }

    /// Current callback query, if the update was produced by an inline button press.
    public var callbackQuery: TGCallbackQuery? {
        self.update.callbackQuery
    }

    /// Raw callback data attached to the current callback query.
    public var callbackData: String? {
        self.callbackQuery?.data
    }

    /// Best-effort resolved Telegram message for the current update.
    ///
    /// This checks regular messages, edited messages, business messages, and
    /// callback queries that still have an accessible backing message.
    public var message: TGMessage? {
        if let message = self.update.message { return message }
        if let message = self.update.editedMessage { return message }
        if let message = self.update.channelPost { return message }
        if let message = self.update.editedChannelPost { return message }
        if let message = self.update.businessMessage { return message }
        if let message = self.update.editedBusinessMessage { return message }
        if case let .some(.message(message)) = self.update.callbackQuery?.message {
            return message
        }
        return nil
    }

    /// Target chat identifier inferred from the current message or callback query.
    public var chatId: Int64? {
        if let message = self.message {
            return message.chat.id
        }
        if let callbackMessage = self.callbackQuery?.message {
            return callbackMessage.chat.id
        }
        return nil
    }

    /// Best-effort resolved user identifier for the current update.
    public var userId: Int64? {
        if let from = self.message?.from {
            return from.id
        }
        return self.callbackQuery?.from.id
    }

    /// Active flow session for the current chat/user scope, if one exists.
    public var activeFlow: TelerouteFlowSession? {
        self.flowSession
    }

    /// Flow scope derived from the current update.
    public var flowKey: TelerouteFlowKey? {
        guard let chatId = self.chatId else {
            return nil
        }
        return .init(chatId: chatId, userId: self.userId)
    }

    /// Replies to the current message when available, otherwise sends a message to the resolved chat.
    public func reply(
        text: String,
        parseMode: TGParseMode? = nil,
        replyMarkup: TGReplyMarkup? = nil
    ) async throws {
        if let message = self.message {
            try await message.reply(
                text: text,
                bot: self.bot,
                parseMode: parseMode,
                replyMarkup: replyMarkup
            )
            return
        }
        try await self.send(
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
        guard let resolvedChatId = chatId ?? self.chatId else {
            throw TelerouteError.chatTargetMissing
        }
        try await self.bot.sendMessage(
            params: .init(
                chatId: .chat(resolvedChatId),
                text: text,
                parseMode: parseMode,
                replyMarkup: replyMarkup
            )
        )
    }

    /// Edits the current message.
    ///
    /// This helper requires a concrete accessible `TGMessage` and will throw
    /// ``TelerouteError/messageTargetMissing`` when the update does not carry one.
    public func edit(
        text: String,
        parseMode: TGParseMode? = nil,
        replyMarkup: TGInlineKeyboardMarkup? = nil
    ) async throws {
        guard let message = self.message else {
            throw TelerouteError.messageTargetMissing
        }
        try await message.edit(
            text: text,
            bot: self.bot,
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
        guard let callbackQuery = self.callbackQuery else {
            throw TelerouteError.callbackQueryMissing
        }
        try await self.bot.answerCallbackQuery(
            params: .init(
                callbackQueryId: callbackQuery.id,
                text: text,
                showAlert: showAlert,
                url: url,
                cacheTime: cacheTime
            )
        )
    }

    /// Starts or replaces the active flow session for the current chat/user scope.
    public func start<Flow: TelerouteFlow>(
        _ flow: Flow.Type,
        at step: Flow.Step,
        values: [String: String] = [:]
    ) async throws {
        let storage = try self.requireFlowStorage()
        let key = try self.requireFlowKey()
        await storage.setSession(
            .init(id: Flow.id, step: step.rawValue, values: .init(values)),
            for: key
        )
    }

    /// Cancels the active flow session for the current chat/user scope.
    public func cancelFlow() async throws {
        let storage = try self.requireFlowStorage()
        let key = try self.requireFlowKey()
        await storage.removeSession(for: key)
    }

    func requireFlowStorage() throws -> any TelerouteFlowStorage {
        guard let flowStorage = self.flowStorage else {
            throw TelerouteError.flowControllerMissing
        }
        return flowStorage
    }

    func requireFlowKey() throws -> TelerouteFlowKey {
        guard let flowKey = self.flowKey else {
            throw TelerouteError.flowScopeMissing
        }
        return flowKey
    }
}
