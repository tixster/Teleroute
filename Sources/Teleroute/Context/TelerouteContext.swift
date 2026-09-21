import Foundation
import Synchronization
import TelegramBotAPI

/// Async route handler invoked with the complete matched-route context.
/// Returns the declarative Telegram effect of the route.
public typealias TelerouteHandler = @Sendable (
    _ context: TelerouteContext
) async throws -> TelerouteResponse

/// Per-update mutable flags shared by every context derived from one update.
public final class TelerouteResponderState: Sendable {
    private let answeredCallbackFlag = Mutex(false)

    public init() {}

    /// Whether the update's callback query has already been answered
    /// (or auto-answering was suppressed).
    public var answeredCallback: Bool {
        self.answeredCallbackFlag.withLock { $0 }
    }

    func markCallbackAnswered() {
        self.answeredCallbackFlag.withLock { $0 = true }
    }
}

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
    /// Default parse mode applied by text helpers when none is passed.
    public let defaultParseMode: ParseMode?
    let parsedUpdate: TelerouteParsedUpdate
    let flowStorage: (any TelerouteFlowStorage)?
    let flowSession: TelerouteFlowSession?
    let responderState: TelerouteResponderState

    /// Creates a context for a matched route.
    public init(
        bot: TelegramBotClient,
        update: Update,
        parameters: TelerouteParameters = .init(),
        command: TelerouteCommandMatch? = nil,
        defaultParseMode: ParseMode? = nil
    ) {
        self.bot = bot
        self.parameters = parameters
        self.command = command
        self.defaultParseMode = defaultParseMode
        self.parsedUpdate = .init(update)
        self.flowStorage = nil
        self.flowSession = nil
        self.responderState = .init()
    }

    init(
        bot: TelegramBotClient,
        parsedUpdate: TelerouteParsedUpdate,
        parameters: TelerouteParameters = .init(),
        command: TelerouteCommandMatch? = nil,
        defaultParseMode: ParseMode? = nil,
        flowStorage: (any TelerouteFlowStorage)?,
        flowSession: TelerouteFlowSession?,
        responderState: TelerouteResponderState = .init()
    ) {
        self.bot = bot
        self.parameters = parameters
        self.command = command
        self.defaultParseMode = defaultParseMode
        self.parsedUpdate = parsedUpdate
        self.flowStorage = flowStorage
        self.flowSession = flowSession
        self.responderState = responderState
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

// MARK: - Rich action execution

extension TelerouteContext {
    func execute(reply: Reply) async throws {
        guard let chatId = self.message?.chat.id ?? self.chatId else {
            throw TelerouteError.chatTargetMissing
        }
        var replyParameters: ReplyParameters?
        if let message = self.message {
            replyParameters = .init(messageId: message.messageId, quote: reply.quote)
        }
        try await self.bot.sendMessage(
            chatId: .id(chatId),
            text: reply.text,
            parseMode: reply.parseMode ?? self.defaultParseMode,
            linkPreviewOptions: reply.options.linkPreviewOptions,
            disableNotification: reply.options.disableNotification,
            protectContent: reply.options.protectContent,
            messageEffectId: reply.options.messageEffectId,
            replyParameters: replyParameters,
            replyMarkup: reply.replyMarkup
        )
    }

    func execute(send: Send) async throws {
        guard let chatId = send.chatId ?? self.chatId.map(ChatId.id) else {
            throw TelerouteError.chatTargetMissing
        }
        try await self.bot.sendMessage(
            chatId: chatId,
            text: send.text,
            messageThreadId: send.options.messageThreadId,
            parseMode: send.parseMode ?? self.defaultParseMode,
            linkPreviewOptions: send.options.linkPreviewOptions,
            disableNotification: send.options.disableNotification,
            protectContent: send.options.protectContent,
            messageEffectId: send.options.messageEffectId,
            replyMarkup: send.replyMarkup
        )
    }

    func execute(edit: Edit) async throws {
        let chatId: ChatId
        let messageId: Int64
        if let explicitMessageId = edit.messageId {
            messageId = explicitMessageId
            guard let chat = edit.chatId ?? self.chatId.map(ChatId.id) else {
                throw TelerouteError.chatTargetMissing
            }
            chatId = chat
        } else {
            guard let message = self.message else {
                throw TelerouteError.messageTargetMissing
            }
            chatId = .id(message.chat.id)
            messageId = message.messageId
        }
        try await self.bot.editMessageText(
            chatId: chatId,
            messageId: messageId,
            text: edit.text,
            parseMode: edit.parseMode ?? self.defaultParseMode,
            replyMarkup: edit.replyMarkup
        )
    }
}

extension TelerouteSendOptions {
    var linkPreviewOptions: LinkPreviewOptions? {
        guard self.linkPreviewDisabled == true else { return nil }
        return .init(isDisabled: true)
    }
}
