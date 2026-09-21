import Foundation

// MARK: - Response generator

/// A value a route handler can return to describe its Telegram effect.
///
/// Conformers include ``TelerouteResponse`` itself, `String` (a plain reply),
/// `Optional` (with `nil` meaning "done, no action"), arrays (a sequence of
/// actions), and the chainable action builders ``Reply``, ``Send``, ``Edit``,
/// ``AnswerCallback``, ``Delete``, and ``React``.
public protocol TelerouteResponseGenerator: Sendable {
    func makeResponse() -> TelerouteResponse
}

/// A declarative Telegram action returned by a route handler or middleware.
public indirect enum TelerouteResponse: Sendable {
    /// Completes the route without sending an additional Telegram request.
    case none
    /// Declares the route did not handle the update; matching continues with
    /// the next candidate route.
    case unhandled
    /// Replies to the current message, or sends to the resolved chat.
    case reply(Reply)
    /// Sends a message to an explicit chat or the chat resolved from the update.
    case send(Send)
    /// Edits the message associated with the current update.
    case edit(Edit)
    /// Answers the current callback query.
    case answerCallback(AnswerCallback)
    /// Deletes the current (or an explicit) message.
    case delete(Delete)
    /// Sets an emoji reaction on the current message.
    case react(React)
    /// Executes multiple responses in their declared order.
    case sequence([TelerouteResponse])

    /// Alias for ``none`` reading better as a handler's final statement.
    public static var done: TelerouteResponse { .none }

    var isUnhandled: Bool {
        if case .unhandled = self { return true }
        return false
    }

    /// Whether executing this response decides the message's inline keyboard
    /// itself.
    ///
    /// `editMessageText` always replaces the markup — omitting `reply_markup`
    /// clears it — so a handler that edits has already said what the keyboard
    /// should be, and automatic button removal must stay out of the way.
    var decidesReplyMarkup: Bool {
        switch self {
        case .edit:
            true
        case let .sequence(responses):
            responses.contains(where: \.decidesReplyMarkup)
        default:
            false
        }
    }
}

extension TelerouteResponse: TelerouteResponseGenerator {
    public func makeResponse() -> TelerouteResponse { self }
}

extension String: TelerouteResponseGenerator {
    /// A bare string is a plain-text reply.
    public func makeResponse() -> TelerouteResponse { .reply(Reply(self)) }
}

extension Optional: TelerouteResponseGenerator where Wrapped: TelerouteResponseGenerator {
    /// `nil` completes the route without an action.
    public func makeResponse() -> TelerouteResponse {
        self?.makeResponse() ?? .none
    }
}

extension Array: TelerouteResponseGenerator where Element: TelerouteResponseGenerator {
    /// An array runs its elements in order.
    public func makeResponse() -> TelerouteResponse {
        .sequence(self.map { $0.makeResponse() })
    }
}

// MARK: - Convenience constructors matching the pre-2.0 case syntax

public extension TelerouteResponse {
    static func reply(
        _ text: String,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) -> TelerouteResponse {
        var reply = Reply(text)
        reply.parseMode = parseMode
        reply.replyMarkup = replyMarkup
        return .reply(reply)
    }

    static func send(
        _ text: String,
        to chatId: ChatId? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) -> TelerouteResponse {
        var send = Send(text, to: chatId)
        send.parseMode = parseMode
        send.replyMarkup = replyMarkup
        return .send(send)
    }

    static func edit(
        _ text: String,
        parseMode: ParseMode? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) -> TelerouteResponse {
        var edit = Edit(text)
        edit.parseMode = parseMode
        edit.replyMarkup = replyMarkup
        return .edit(edit)
    }

    static func answerCallback(
        _ text: String? = nil,
        showAlert: Bool? = nil,
        url: String? = nil,
        cacheTime: Int64? = nil
    ) -> TelerouteResponse {
        .answerCallback(AnswerCallback(
            text: text,
            showAlert: showAlert,
            url: url,
            cacheTime: cacheTime
        ))
    }

    /// Deletes the message carried by the current update.
    static var deleteMessage: TelerouteResponse { .delete(Delete()) }

    /// Sets one emoji reaction on the current message.
    static func react(_ emoji: String, big: Bool? = nil) -> TelerouteResponse {
        .react(React(emoji, big: big))
    }
}

// MARK: - Chainable action builders

/// Common send-style options shared by ``Reply`` and ``Send``.
public struct TelerouteSendOptions: Sendable {
    public var disableNotification: Bool?
    public var protectContent: Bool?
    public var messageEffectId: String?
    public var linkPreviewDisabled: Bool?
    public var messageThreadId: Int64?

    init() {}
}

/// Reply to the update's message.
public struct Reply: TelerouteResponseGenerator, Sendable {
    public var text: String
    public var parseMode: ParseMode?
    public var replyMarkup: ReplyMarkup?
    /// Buttons rendered against the serving router when the response executes.
    /// Set by the keyboard-builder form of `keyboard(_:)`; takes precedence
    /// over ``replyMarkup``.
    public var buttons: [[TelerouteButton]]?
    /// Optional exact passage of the original message to quote.
    public var quote: String?
    public var options = TelerouteSendOptions()

    public init(_ text: String) {
        self.text = text
    }

    public func parseMode(_ mode: ParseMode) -> Self { var copy = self; copy.parseMode = mode; return copy }
    public func keyboard(_ markup: ReplyMarkup) -> Self { var copy = self; copy.replyMarkup = markup; return copy }
    public func keyboard(_ markup: InlineKeyboardMarkup) -> Self { var copy = self; copy.replyMarkup = .inline(markup); return copy }
    /// Attaches an inline keyboard built with the result-builder DSL.
    ///
    /// Typed callback buttons are validated against the router serving the
    /// update when the response executes, so the markup can be described
    /// inline in the handler body:
    ///
    /// ```swift
    /// router.command("orders") { _ in
    ///     Reply("Your orders:").keyboard {
    ///         Row { page.button(OrderPage(id: "7", page: 1), "Next") }
    ///     }
    /// }
    /// ```
    public func keyboard(
        @TelerouteKeyboardBuilder _ content: () -> [[TelerouteButton]]
    ) -> Self {
        var copy = self
        copy.buttons = content()
        return copy
    }
    /// Removes the user's reply keyboard.
    public func removeKeyboard(selective: Bool? = nil) -> Self {
        var copy = self
        copy.replyMarkup = .remove(.init(removeKeyboard: true, selective: selective))
        return copy
    }
    /// Shows the user a forced reply prompt.
    public func forceReply(placeholder: String? = nil, selective: Bool? = nil) -> Self {
        var copy = self
        copy.replyMarkup = .forceReply(.init(
            forceReply: true,
            inputFieldPlaceholder: placeholder,
            selective: selective
        ))
        return copy
    }
    /// Quotes a specific passage of the original message in the reply.
    public func quoting(_ passage: String) -> Self {
        var copy = self
        copy.quote = passage
        return copy
    }
    public func silent(_ on: Bool = true) -> Self { var copy = self; copy.options.disableNotification = on; return copy }
    public func protected(_ on: Bool = true) -> Self { var copy = self; copy.options.protectContent = on; return copy }
    public func effect(_ id: String) -> Self { var copy = self; copy.options.messageEffectId = id; return copy }
    public func withoutLinkPreview() -> Self { var copy = self; copy.options.linkPreviewDisabled = true; return copy }

    public func makeResponse() -> TelerouteResponse { .reply(self) }
}

/// Send a message to an explicit chat (or the resolved one).
public struct Send: TelerouteResponseGenerator, Sendable {
    public var text: String
    public var chatId: ChatId?
    public var parseMode: ParseMode?
    public var replyMarkup: ReplyMarkup?
    /// Buttons rendered against the serving router when the response executes.
    public var buttons: [[TelerouteButton]]?
    public var options = TelerouteSendOptions()

    public init(_ text: String, to chatId: ChatId? = nil) {
        self.text = text
        self.chatId = chatId
    }

    public func parseMode(_ mode: ParseMode) -> Self { var copy = self; copy.parseMode = mode; return copy }
    public func keyboard(_ markup: ReplyMarkup) -> Self { var copy = self; copy.replyMarkup = markup; return copy }
    public func keyboard(_ markup: InlineKeyboardMarkup) -> Self { var copy = self; copy.replyMarkup = .inline(markup); return copy }
    /// Attaches an inline keyboard built with the result-builder DSL, rendered
    /// against the serving router when the response executes.
    public func keyboard(
        @TelerouteKeyboardBuilder _ content: () -> [[TelerouteButton]]
    ) -> Self {
        var copy = self
        copy.buttons = content()
        return copy
    }
    /// Removes the user's reply keyboard.
    public func removeKeyboard(selective: Bool? = nil) -> Self {
        var copy = self
        copy.replyMarkup = .remove(.init(removeKeyboard: true, selective: selective))
        return copy
    }
    /// Shows the user a forced reply prompt.
    public func forceReply(placeholder: String? = nil, selective: Bool? = nil) -> Self {
        var copy = self
        copy.replyMarkup = .forceReply(.init(
            forceReply: true,
            inputFieldPlaceholder: placeholder,
            selective: selective
        ))
        return copy
    }
    public func silent(_ on: Bool = true) -> Self { var copy = self; copy.options.disableNotification = on; return copy }
    public func protected(_ on: Bool = true) -> Self { var copy = self; copy.options.protectContent = on; return copy }
    public func effect(_ id: String) -> Self { var copy = self; copy.options.messageEffectId = id; return copy }
    public func withoutLinkPreview() -> Self { var copy = self; copy.options.linkPreviewDisabled = true; return copy }
    public func thread(_ id: Int64) -> Self { var copy = self; copy.options.messageThreadId = id; return copy }

    public func makeResponse() -> TelerouteResponse { .send(self) }
}

/// Edit the update's message (or an explicit one).
public struct Edit: TelerouteResponseGenerator, Sendable {
    public var text: String
    public var parseMode: ParseMode?
    public var replyMarkup: InlineKeyboardMarkup?
    /// Buttons rendered against the serving router when the response executes.
    public var buttons: [[TelerouteButton]]?
    public var messageId: Int64?
    public var chatId: ChatId?

    public init(_ text: String) {
        self.text = text
    }

    public func parseMode(_ mode: ParseMode) -> Self { var copy = self; copy.parseMode = mode; return copy }
    public func keyboard(_ markup: InlineKeyboardMarkup) -> Self { var copy = self; copy.replyMarkup = markup; return copy }
    /// Attaches an inline keyboard built with the result-builder DSL, rendered
    /// against the serving router when the response executes.
    public func keyboard(
        @TelerouteKeyboardBuilder _ content: () -> [[TelerouteButton]]
    ) -> Self {
        var copy = self
        copy.buttons = content()
        return copy
    }
    public func message(_ id: Int64, in chat: ChatId? = nil) -> Self {
        var copy = self
        copy.messageId = id
        copy.chatId = chat
        return copy
    }

    public func makeResponse() -> TelerouteResponse { .edit(self) }
}

/// Answer the update's callback query.
public struct AnswerCallback: TelerouteResponseGenerator, Sendable {
    public var text: String?
    public var showAlert: Bool?
    public var url: String?
    public var cacheTime: Int64?

    public init(
        text: String? = nil,
        showAlert: Bool? = nil,
        url: String? = nil,
        cacheTime: Int64? = nil
    ) {
        self.text = text
        self.showAlert = showAlert
        self.url = url
        self.cacheTime = cacheTime
    }

    public func alert() -> Self { var copy = self; copy.showAlert = true; return copy }

    public func makeResponse() -> TelerouteResponse { .answerCallback(self) }
}

/// Delete the update's message (or an explicit one).
public struct Delete: TelerouteResponseGenerator, Sendable {
    public var messageId: Int64?
    public var chatId: ChatId?

    public init(messageId: Int64? = nil, in chatId: ChatId? = nil) {
        self.messageId = messageId
        self.chatId = chatId
    }

    public func makeResponse() -> TelerouteResponse { .delete(self) }
}

/// Set an emoji reaction on the update's message.
public struct React: TelerouteResponseGenerator, Sendable {
    public var emoji: String
    public var big: Bool?

    public init(_ emoji: String, big: Bool? = nil) {
        self.emoji = emoji
        self.big = big
    }

    public func makeResponse() -> TelerouteResponse { .react(self) }
}

/// Marker declaring the route did not handle the update.
public struct TelerouteUnhandled: TelerouteResponseGenerator, Sendable {
    public init() {}
    public func makeResponse() -> TelerouteResponse { .unhandled }
}

// MARK: - Execution

extension TelerouteResponse {
    func execute(in context: TelerouteContext) async throws {
        switch self {
        case .none, .unhandled:
            return

        case let .reply(reply):
            try await context.execute(reply: reply)

        case let .send(send):
            try await context.execute(send: send)

        case let .edit(edit):
            try await context.execute(edit: edit)

        case let .answerCallback(answer):
            try await context.answerCallbackQuery(
                answer.text,
                showAlert: answer.showAlert,
                url: answer.url,
                cacheTime: answer.cacheTime
            )

        case let .delete(delete):
            try await context.deleteMessage(
                messageId: delete.messageId,
                in: delete.chatId
            )

        case let .react(react):
            try await context.react(react.emoji, big: react.big)

        case let .sequence(responses):
            for response in responses {
                try await response.execute(in: context)
            }
        }
    }
}
