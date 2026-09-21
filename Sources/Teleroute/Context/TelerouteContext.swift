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
    /// Request-scoped logger, pre-populated with this update's metadata
    /// (`update_id`, `chat_id`, `user_id`, `route_kind`, and the matched
    /// command or callback data). Inside a flow step it also carries
    /// `flow_id` and `flow_step`.
    public internal(set) var logger: Logger
    let parsedUpdate: TelerouteParsedUpdate
    let flowStorage: (any TelerouteFlowStorage)?
    let flowSession: TelerouteFlowSession?
    /// Configured flow-session TTL, applied when a flow declares no override.
    let flowSessionTTL: Duration?
    /// Sink notified when a flow session ends. `nil` for contexts built
    /// directly by the public initializer.
    let metricsSink: (any TelerouteMetricsSink)?
    let responderState: TelerouteResponderState
    /// Route scope used to render keyboards and callback data from a handler.
    /// `nil` for contexts built directly by the public initializer.
    let routeScope: TelerouteRoutes?
    /// Registry backing buttons that carry an inline handler. `nil` when the
    /// feature is disabled or the context was built directly.
    let inlineActions: TelerouteInlineActionStore?

    /// Logger used by contexts built outside a running router.
    public static let defaultLogger = Logger(label: "teleroute.context")

    /// Creates a context for a matched route.
    public init(
        bot: TelegramBotClient,
        update: Update,
        parameters: TelerouteParameters = .init(),
        command: TelerouteCommandMatch? = nil,
        defaultParseMode: ParseMode? = nil,
        logger: Logger = TelerouteContext.defaultLogger
    ) {
        self.bot = bot
        self.parameters = parameters
        self.command = command
        self.defaultParseMode = defaultParseMode
        self.logger = logger
        self.parsedUpdate = .init(update)
        self.flowStorage = nil
        self.flowSession = nil
        self.flowSessionTTL = nil
        self.metricsSink = nil
        self.responderState = .init()
        self.routeScope = nil
        self.inlineActions = nil
    }

    /// Internal initializer used by the running router. `logger` is deliberately
    /// non-defaulted so any new construction site has to decide what to pass.
    init(
        bot: TelegramBotClient,
        parsedUpdate: TelerouteParsedUpdate,
        parameters: TelerouteParameters = .init(),
        command: TelerouteCommandMatch? = nil,
        defaultParseMode: ParseMode? = nil,
        logger: Logger,
        flowStorage: (any TelerouteFlowStorage)?,
        flowSession: TelerouteFlowSession?,
        flowSessionTTL: Duration? = nil,
        metricsSink: (any TelerouteMetricsSink)? = nil,
        responderState: TelerouteResponderState = .init(),
        routeScope: TelerouteRoutes? = nil,
        inlineActions: TelerouteInlineActionStore? = nil
    ) {
        self.bot = bot
        self.parameters = parameters
        self.command = command
        self.defaultParseMode = defaultParseMode
        self.logger = logger
        self.parsedUpdate = parsedUpdate
        self.flowStorage = flowStorage
        self.flowSession = flowSession
        self.flowSessionTTL = flowSessionTTL
        self.metricsSink = metricsSink
        self.responderState = responderState
        self.routeScope = routeScope
        self.inlineActions = inlineActions
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

    /// The Telegram user behind the current update.
    ///
    /// Resolved for every update kind that carries one — messages, callback
    /// queries, inline queries, join requests, reactions, pre-checkout
    /// queries, and the rest — so handlers rarely need
    /// `message?.from` and its optional chain.
    public var user: User? {
        self.parsedUpdate.user
    }

    /// The chat the current update belongs to, when it has one.
    public var chat: Chat? {
        self.message?.chat ?? self.callbackQuery?.message?.chat
    }

    /// Active flow session for the current chat/user scope, if one exists.
    public var activeFlow: TelerouteFlowSession? {
        self.flowSession
    }

    /// Flow scope derived from the current update.
    public var flowKey: TelerouteFlowKey? {
        self.parsedUpdate.flowKey
    }

    /// Returns a copy of this context whose logger carries additional metadata.
    public func logging(metadata: Logger.Metadata) -> TelerouteContext {
        var copy = self
        for (key, value) in metadata {
            copy.logger[metadataKey: key] = value
        }
        return copy
    }

    /// Reports a finished flow session to the configured metrics sink.
    func reportFlowEnded(
        _ session: TelerouteFlowSession,
        outcome: TelerouteFlowOutcome,
        key: TelerouteFlowKey
    ) async {
        guard let metricsSink = self.metricsSink else { return }
        let age = Date().timeIntervalSince(session.createdAt)
        await metricsSink.recordFlowEnded(
            flowID: session.id,
            step: session.step,
            outcome: outcome,
            age: .seconds(max(age, 0)),
            chatId: key.chatId,
            userId: key.userId
        )
    }

    /// Reports a finished session to the metrics sink and hands it to the
    /// flow's `onEnd` hook, if one was registered.
    ///
    /// Reached through `routeScope`, which already carries the registration
    /// storage — the same lookup the flow coordinator uses, so the two teardown
    /// families cannot diverge.
    func endFlowSession(
        _ session: TelerouteFlowSession,
        reason: TelerouteFlowEndReason,
        key: TelerouteFlowKey
    ) async {
        await self.reportFlowEnded(session, outcome: reason.outcome, key: key)
        guard let onEnd = self.routeScope?.storage.routeGraph.flowHooks[session.id]?.onEnd else {
            return
        }
        await onEnd(.init(coreContext: self, endedSession: session), reason)
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
            replyMarkup: try self.resolvedReplyMarkup(
                reply.replyMarkup,
                buttons: reply.buttons
            )
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
            replyMarkup: try self.resolvedReplyMarkup(
                send.replyMarkup,
                buttons: send.buttons
            )
        )
    }

    func execute(edit: Edit) async throws {
        let replyMarkup = try self.resolvedInlineMarkup(
            edit.replyMarkup,
            buttons: edit.buttons
        )
        let target = try self.resolvedEditTarget(messageId: edit.messageId, in: edit.chatId)
        try await self.bot.editMessageText(
            chatId: target.chatId,
            messageId: target.messageId,
            inlineMessageId: target.inlineMessageId,
            text: edit.text,
            parseMode: edit.parseMode ?? self.defaultParseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Renders buttons declared with the deferred keyboard builder against the
    /// router serving this update, falling back to an explicit markup.
    private func resolvedReplyMarkup(
        _ markup: ReplyMarkup?,
        buttons: [[TelerouteButton]]?
    ) throws -> ReplyMarkup? {
        guard let buttons else { return markup }
        return .inline(try self.renderKeyboard(buttons))
    }

    private func resolvedInlineMarkup(
        _ markup: InlineKeyboardMarkup?,
        buttons: [[TelerouteButton]]?
    ) throws -> InlineKeyboardMarkup? {
        guard let buttons else { return markup }
        return try self.renderKeyboard(buttons)
    }

    private func renderKeyboard(
        _ buttons: [[TelerouteButton]]
    ) throws -> InlineKeyboardMarkup {
        guard let routeScope = self.routeScope else {
            throw TelerouteError.keyboardScopeMissing
        }
        return try routeScope.keyboard(buttons, in: self.renderContext)
    }

    /// Everything a button needs beyond the route scope: where to park an
    /// inline handler, and who the keyboard is being rendered for.
    var renderContext: TelerouteRenderContext {
        .init(
            inlineActions: self.inlineActions,
            chatId: self.chatId,
            userId: self.userId
        )
    }
}

extension TelerouteSendOptions {
    var linkPreviewOptions: LinkPreviewOptions? {
        guard self.linkPreviewDisabled == true else { return nil }
        return .init(isDisabled: true)
    }
}
