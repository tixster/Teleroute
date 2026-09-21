import Foundation
import TelegramBotAPI

/// Framework-owned input used to construct a custom request context.
public struct TelerouteContextSource: Sendable {
    /// The complete Telegram route context created for the matched update.
    public let coreContext: TelerouteContext

    public init(coreContext: TelerouteContext) {
        self.coreContext = coreContext
    }
}

/// A statically typed context delivered to handlers registered on a
/// ``Teleroute``.
///
/// Store lightweight request-scoped values here and keep shared services as
/// references. The framework context remains available through ``coreContext``,
/// and every Telegram convenience helper (messaging, media, chat management,
/// flows) is available directly on any conforming context.
public protocol TelerouteRequestContext: Sendable {
    /// Framework context containing the update, route parameters, bot, and
    /// Telegram convenience methods.
    var coreContext: TelerouteContext { get }
}

/// A request context that can be constructed directly from a matched update.
public protocol TelerouteInitializableRequestContext: TelerouteRequestContext {
    init(source: TelerouteContextSource) async throws
}

/// A context produced from a parent context for a nested route group.
///
/// Child contexts are useful for progressively refining guarantees, for
/// example turning an optional authenticated user into a required admin user.
public protocol TelerouteChildRequestContext<ParentContext>: TelerouteRequestContext {
    associatedtype ParentContext: TelerouteRequestContext

    init(context: ParentContext) async throws
}

// MARK: - Data accessors

public extension TelerouteRequestContext {
    /// Raw Telegram update currently being processed.
    var update: Update { self.coreContext.update }
    /// Bot associated with the running application.
    var bot: TelegramBotClient { self.coreContext.bot }
    /// Parameters extracted from a callback route.
    var parameters: TelerouteParameters { self.coreContext.parameters }
    /// Parsed command metadata, when this is a command route.
    var command: TelerouteCommandMatch? { self.coreContext.command }
    /// Current callback query, if any.
    var callbackQuery: CallbackQuery? { self.coreContext.callbackQuery }
    /// Raw callback data, if any.
    var callbackData: String? { self.coreContext.callbackData }
    /// Best-effort Telegram message resolved from the update.
    var message: Message? { self.coreContext.message }
    /// Resolved chat identifier.
    var chatId: Int64? { self.coreContext.chatId }
    /// Resolved chat type.
    var chatType: ChatType? { self.coreContext.chatType }
    /// Resolved Telegram user identifier.
    var userId: Int64? { self.coreContext.userId }
    /// The Telegram user behind the current update, for every update kind that
    /// carries one.
    var user: User? { self.coreContext.user }
    /// The chat the current update belongs to, when it has one.
    var chat: Chat? { self.coreContext.chat }
    /// The update's kind, when it carries a known payload.
    var updateKind: UpdateKind? { self.coreContext.updateKind }
    /// Which update field produced ``message``.
    var messageSource: TelerouteMessageSource? { self.coreContext.messageSource }
    /// Default parse mode applied by text helpers.
    var defaultParseMode: ParseMode? { self.coreContext.defaultParseMode }
    /// Request-scoped logger carrying this update's metadata.
    var logger: Logger { self.coreContext.logger }
    /// Active flow session, if one exists.
    var activeFlow: TelerouteFlowSession? { self.coreContext.activeFlow }
    /// Flow key derived from the current update.
    var flowKey: TelerouteFlowKey? { self.coreContext.flowKey }

    /// Typed update payload accessors.
    var inlineQuery: InlineQuery? { self.update.inlineQuery }
    var chosenInlineResult: ChosenInlineResult? { self.update.chosenInlineResult }
    var shippingQuery: ShippingQuery? { self.update.shippingQuery }
    var preCheckoutQuery: PreCheckoutQuery? { self.update.preCheckoutQuery }
    var chatMemberUpdated: ChatMemberUpdated? {
        self.update.chatMember ?? self.update.myChatMember
    }
    var chatJoinRequest: ChatJoinRequest? { self.update.chatJoinRequest }
    var messageReaction: MessageReactionUpdated? { self.update.messageReaction }
    var poll: Poll? { self.update.poll }
    var pollAnswer: PollAnswer? { self.update.pollAnswer }
}

// MARK: - Target resolution

public extension TelerouteRequestContext {
    /// Resolves the target chat for a send operation, preferring an explicit
    /// override and falling back to the chat inferred from the current update.
    func resolvedChat(_ override: ChatId? = nil) throws -> ChatId {
        if let override { return override }
        guard let resolved = self.chatId else {
            throw TelerouteError.chatTargetMissing
        }
        return .id(resolved)
    }

    /// Resolves a message id, preferring an explicit override and falling back
    /// to the message carried by the current update.
    func resolvedMessageId(_ override: Int64? = nil) throws -> Int64 {
        guard let resolved = override ?? self.message?.messageId else {
            throw TelerouteError.messageTargetMissing
        }
        return resolved
    }

    /// Returns the update's message or throws when it carries none.
    ///
    /// Prefer this over unwrapping ``message`` by hand: the thrown error goes
    /// through the router's normal error pipeline, so it reaches `onError`,
    /// the `errorRenderer`, events, and metrics like any other failure.
    func requireMessage() throws -> Message {
        guard let message = self.message else {
            throw TelerouteError.messageTargetMissing
        }
        return message
    }

    /// Returns the resolved chat identifier or throws when the update has none.
    func requireChatId() throws -> Int64 {
        guard let chatId = self.chatId else {
            throw TelerouteError.chatTargetMissing
        }
        return chatId
    }

    /// Returns the Telegram user behind the update or throws when it has none.
    func requireUser() throws -> User {
        guard let user = self.user else {
            throw TelerouteError.userTargetMissing
        }
        return user
    }

    /// Returns the resolved user identifier or throws when the update has none.
    func requireUserId() throws -> Int64 {
        guard let userId = self.userId else {
            throw TelerouteError.userTargetMissing
        }
        return userId
    }

    /// Returns the current callback query or throws when the update is not a
    /// button press.
    func requireCallbackQuery() throws -> CallbackQuery {
        guard let callbackQuery = self.callbackQuery else {
            throw TelerouteError.callbackQueryMissing
        }
        return callbackQuery
    }

    /// Returns the matched command or throws when this is not a command route.
    func requireCommand() throws -> TelerouteCommandMatch {
        guard let command = self.command else {
            throw TelerouteError.commandMatchMissing
        }
        return command
    }

    /// Resolves what an edit should be applied to.
    ///
    /// Telegram addresses editable messages two different ways, and a callback
    /// query can arrive in either form: an ordinary message has a chat and a
    /// message id, while a message sent through inline mode has only an
    /// `inline_message_id`. This picks whichever the update actually carries,
    /// so one call site handles both:
    ///
    /// ```swift
    /// switch try context.resolvedEditTarget() {
    /// case let .message(chatId, messageId):
    ///     try await context.bot.editMessageMedia(chatId: chatId, messageId: messageId, media: media)
    /// case let .inline(inlineMessageId):
    ///     try await context.bot.editMessageMedia(inlineMessageId: inlineMessageId, media: media)
    /// }
    /// ```
    ///
    /// A message the bot can no longer read still resolves: an
    /// `InaccessibleMessage` carries its chat and id, so the edit is attempted
    /// and Telegram decides whether it is still allowed.
    ///
    /// - Parameters:
    ///   - messageId: Targets this message instead of the update's own.
    ///   - chat: Targets this chat instead of the resolved one.
    func resolvedEditTarget(
        messageId: Int64? = nil,
        in chat: ChatId? = nil
    ) throws -> TelerouteEditTarget {
        if let messageId {
            return .message(chatId: try self.resolvedChat(chat), messageId: messageId)
        }
        if let message = self.message {
            return .message(
                chatId: chat ?? .id(message.chat.id),
                messageId: message.messageId
            )
        }
        // No accessible message: an inline-mode message has no chat at all,
        // and an inaccessible one still has a usable chat and id.
        if let inlineMessageId = self.callbackQuery?.inlineMessageId {
            return .inline(messageId: inlineMessageId)
        }
        if let hosted = self.callbackQuery?.message {
            return .message(
                chatId: chat ?? .id(hosted.chat.id),
                messageId: hosted.messageId
            )
        }
        throw TelerouteError.messageTargetMissing
    }
}

/// What an edit applies to: an ordinary chat message, or a message sent
/// through inline mode, which Telegram addresses by `inline_message_id` and
/// which has no chat or message id at all.
public enum TelerouteEditTarget: Sendable, Equatable {
    case message(chatId: ChatId, messageId: Int64)
    case inline(messageId: String)
}

public extension TelerouteEditTarget {
    /// The chat to edit in, or `nil` for an inline-mode message.
    ///
    /// Every Bot API edit operation takes `chatId`, `messageId`, and
    /// `inlineMessageId` as three optionals and uses whichever pair is
    /// present, so destructuring a target through these three properties is
    /// enough to address either form in one call:
    ///
    /// ```swift
    /// let target = try context.resolvedEditTarget()
    /// try await context.bot.editMessageMedia(
    ///     chatId: target.chatId,
    ///     messageId: target.messageId,
    ///     inlineMessageId: target.inlineMessageId,
    ///     media: media
    /// )
    /// ```
    var chatId: ChatId? {
        switch self {
        case let .message(chatId, _): chatId
        case .inline: nil
        }
    }

    /// The message to edit, or `nil` for an inline-mode message.
    var messageId: Int64? {
        switch self {
        case let .message(_, messageId): messageId
        case .inline: nil
        }
    }

    /// The inline-mode message to edit, or `nil` for an ordinary message.
    var inlineMessageId: String? {
        switch self {
        case .message: nil
        case let .inline(messageId): messageId
        }
    }
}

// MARK: - Flow control

public extension TelerouteRequestContext {
    /// Starts or replaces a flow session.
    func start<Flow: TelerouteFlow>(
        _ flow: Flow.Type,
        at step: Flow.Step,
        values: [String: String] = [:]
    ) async throws {
        let storage = try self.coreContext.requireFlowStorage()
        let key = try self.coreContext.requireFlowKey()
        // Starting replaces whatever was there, but still goes through
        // updateSession so every flow write takes the same path — and so an
        // atomic backend applies it as one operation.
        let ttl = Flow.sessionTTL ?? self.coreContext.flowSessionTTL
        let now = Date()
        await storage.updateSession(for: key) { _ in
            .init(
                id: Flow.id,
                step: step.rawValue,
                values: .init(values),
                createdAt: now,
                updatedAt: now,
                expiresAt: ttl.map {
                    now.addingTimeInterval(TimeInterval($0.components.seconds))
                }
            )
        }
    }

    /// Cancels the active flow session.
    func cancelFlow() async throws {
        try await self.endFlow(outcome: .cancelled)
    }

    /// Ends the active flow session and reports how it ended.
    func endFlow(outcome: TelerouteFlowOutcome) async throws {
        let storage = try self.coreContext.requireFlowStorage()
        let key = try self.coreContext.requireFlowKey()
        let ended = await storage.session(for: key)
        await storage.removeSession(for: key)
        if let ended {
            await self.coreContext.reportFlowEnded(ended, outcome: outcome, key: key)
        }
    }
}

extension TelerouteContext: TelerouteInitializableRequestContext {
    public var coreContext: TelerouteContext {
        self
    }

    public init(source: TelerouteContextSource) {
        self = source.coreContext
    }
}
