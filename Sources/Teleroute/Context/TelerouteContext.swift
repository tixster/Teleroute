import Foundation

/// Async route handler invoked with the complete matched-route context.
public typealias TelerouteHandler = @Sendable (_ context: TelerouteContext) async throws -> Void

/// Context passed to router handlers.
///
/// It exposes the matched command, callback data, decoded route parameters,
/// and a set of helpers for replying through the Telegram Bot API client.
public struct TelerouteContext: Sendable {
    /// Bot instance associated with the router.
    public let bot: TelegramBotClient
    /// Route parameters extracted from a callback pattern.
    public let parameters: TelerouteParameters
    /// Parsed command metadata when the handler was invoked by a command route.
    public let command: TelerouteCommandMatch?
    let parsedUpdate: TelerouteParsedUpdate
    let flowStorage: (any TelerouteFlowStorage)?
    let flowSession: TelerouteFlowSession?

    /// Creates a context for a matched route.
    public init(
        bot: TelegramBotClient,
        update: Update,
        parameters: TelerouteParameters = .init(),
        command: TelerouteCommandMatch? = nil
    ) {
        self.bot = bot
        self.parameters = parameters
        self.command = command
        self.parsedUpdate = .init(update)
        self.flowStorage = nil
        self.flowSession = nil
    }

    init(
        bot: TelegramBotClient,
        parsedUpdate: TelerouteParsedUpdate,
        parameters: TelerouteParameters = .init(),
        command: TelerouteCommandMatch? = nil,
        flowStorage: (any TelerouteFlowStorage)?,
        flowSession: TelerouteFlowSession?
    ) {
        self.bot = bot
        self.parameters = parameters
        self.command = command
        self.parsedUpdate = parsedUpdate
        self.flowStorage = flowStorage
        self.flowSession = flowSession
    }

    /// Raw Telegram update currently being processed.
    public var update: Update {
        self.parsedUpdate.update
    }

    /// Current callback query, if the update was produced by an inline button press.
    public var callbackQuery: CallbackQuery? {
        self.parsedUpdate.callbackQuery
    }

    /// Raw callback data attached to the current callback query.
    public var callbackData: String? {
        self.parsedUpdate.callbackData
    }

    /// Best-effort resolved Telegram message for the current update.
    ///
    /// This checks regular messages, edited messages, business messages, and
    /// callback queries that still have an accessible backing message.
    public var message: Message? {
        self.parsedUpdate.message
    }

    /// Target chat identifier inferred from the current message or callback query.
    public var chatId: Int64? {
        self.parsedUpdate.chatId
    }

    /// Telegram chat type inferred from the current message or callback query.
    public var chatType: ChatType? {
        self.parsedUpdate.chatType
    }

    /// Best-effort resolved user identifier for the current update.
    public var userId: Int64? {
        self.parsedUpdate.userId
    }

    /// Active flow session for the current chat/user scope, if one exists.
    public var activeFlow: TelerouteFlowSession? {
        self.flowSession
    }

    /// Flow scope derived from the current update.
    public var flowKey: TelerouteFlowKey? {
        self.parsedUpdate.flowKey
    }

    /// Replies to the current message when available, otherwise sends a message to the resolved chat.
    public func reply(
        _ text: String,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws {
        try await self.send(
            text,
            to: self.message?.chat.id,
            parseMode: parseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Sends a message to the supplied chat or to the chat inferred from the current update.
    public func send(
        _ text: String,
        to chatId: Int64? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws {
        guard let resolvedChatId = chatId ?? self.chatId else {
            throw TelerouteError.chatTargetMissing
        }
        try await self.bot.sendMessage(
            chatId: .id(resolvedChatId),
            text: text,
            parseMode: parseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Edits the current message.
    ///
    /// This helper requires a concrete accessible `Message` and will throw
    /// ``TelerouteError/messageTargetMissing`` when the update does not carry one.
    public func edit(
        _ text: String,
        parseMode: ParseMode? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) async throws {
        guard let message = self.message else {
            throw TelerouteError.messageTargetMissing
        }
        try await self.bot.editMessageText(
            chatId: .id(message.chat.id),
            messageId: message.messageId,
            text: text,
            parseMode: parseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Answers the current callback query.
    public func answerCallbackQuery(
        _ text: String? = nil,
        showAlert: Bool? = nil,
        url: String? = nil,
        cacheTime: Int? = nil
    ) async throws {
        guard let callbackQuery = self.callbackQuery else {
            throw TelerouteError.callbackQueryMissing
        }
        try await self.bot.answerCallbackQuery(
            callbackQueryId: callbackQuery.id,
            text: text,
            showAlert: showAlert,
            url: url,
            cacheTime: cacheTime.map(Int64.init)
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
