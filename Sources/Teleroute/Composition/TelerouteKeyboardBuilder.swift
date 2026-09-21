import Foundation
import TelegramBotAPI

// MARK: - Inline keyboard result builders

/// One row of an inline keyboard built with ``TelerouteRowBuilder``.
public struct Row: Sendable {
    public let buttons: [TelerouteButton]

    public init(@TelerouteRowBuilder _ content: () -> [TelerouteButton]) {
        self.buttons = content()
    }
}

/// Builds one keyboard row from button expressions.
@resultBuilder
public enum TelerouteRowBuilder {
    public static func buildBlock(_ buttons: [TelerouteButton]...) -> [TelerouteButton] {
        buttons.flatMap { $0 }
    }

    public static func buildExpression(_ button: TelerouteButton) -> [TelerouteButton] {
        [button]
    }

    public static func buildExpression(_ button: InlineKeyboardButton) -> [TelerouteButton] {
        [.raw(button)]
    }

    public static func buildExpression(_ buttons: [TelerouteButton]) -> [TelerouteButton] {
        buttons
    }

    public static func buildOptional(_ buttons: [TelerouteButton]?) -> [TelerouteButton] {
        buttons ?? []
    }

    public static func buildEither(first: [TelerouteButton]) -> [TelerouteButton] { first }
    public static func buildEither(second: [TelerouteButton]) -> [TelerouteButton] { second }
    public static func buildArray(_ rows: [[TelerouteButton]]) -> [TelerouteButton] {
        rows.flatMap { $0 }
    }
}

/// Builds keyboard rows from ``Row`` expressions (a bare button expression
/// becomes its own row).
@resultBuilder
public enum TelerouteKeyboardBuilder {
    public static func buildBlock(_ rows: [[TelerouteButton]]...) -> [[TelerouteButton]] {
        rows.flatMap { $0 }
    }

    public static func buildExpression(_ row: Row) -> [[TelerouteButton]] {
        [row.buttons]
    }

    public static func buildExpression(_ button: TelerouteButton) -> [[TelerouteButton]] {
        [[button]]
    }

    /// Splices in rows produced elsewhere, such as by
    /// ``Swift/Array/grid(columns:)`` or ``TeleroutePagination``.
    public static func buildExpression(_ rows: [[TelerouteButton]]) -> [[TelerouteButton]] {
        rows
    }

    public static func buildOptional(_ rows: [[TelerouteButton]]?) -> [[TelerouteButton]] {
        rows ?? []
    }

    public static func buildEither(first: [[TelerouteButton]]) -> [[TelerouteButton]] { first }
    public static func buildEither(second: [[TelerouteButton]]) -> [[TelerouteButton]] { second }
    public static func buildArray(_ rows: [[[TelerouteButton]]]) -> [[TelerouteButton]] {
        rows.flatMap { $0 }
    }
}

public extension TelerouteRouterGroup {
    /// Renders a keyboard described with the result-builder DSL, validating
    /// typed callbacks against this scope:
    ///
    /// ```swift
    /// let markup = try router.keyboard {
    ///     Row {
    ///         approve.button(ApproveOrder(id: "1"), "Approve")
    ///         TelerouteButton.url("Docs", "https://example.com")
    ///     }
    ///     TelerouteButton.switchInlineQuery("Share", query: "cats")
    /// }
    /// ```
    func keyboard(
        @TelerouteKeyboardBuilder _ content: () -> [[TelerouteButton]]
    ) throws -> InlineKeyboardMarkup {
        try self.keyboard(content())
    }
}

@_spi(Testing)
public extension TelerouteRoutes {
    /// Renders a keyboard described with the result-builder DSL in this scope.
    func keyboard(
        @TelerouteKeyboardBuilder _ content: () -> [[TelerouteButton]]
    ) throws -> InlineKeyboardMarkup {
        try self.keyboard(content())
    }
}

// MARK: - Reply keyboards

/// One reply-keyboard button with chainable request options.
public struct KeyButton: Sendable {
    var button: KeyboardButton

    public init(_ text: String) {
        self.button = .init(text: text)
    }

    /// Requests the user's phone number when pressed.
    public func requestContact() -> Self {
        var copy = self
        copy.button.requestContact = true
        return copy
    }

    /// Requests the user's location when pressed.
    public func requestLocation() -> Self {
        var copy = self
        copy.button.requestLocation = true
        return copy
    }

    /// Opens a user picker; the selection arrives as a `users_shared`
    /// service message carrying `requestId`.
    public func requestUsers(_ request: KeyboardButtonRequestUsers) -> Self {
        var copy = self
        copy.button.requestUsers = request
        return copy
    }

    /// Opens a user picker with the common options spelled out.
    public func requestUsers(
        id requestId: Int64,
        maxQuantity: Int64? = nil,
        userIsBot: Bool? = nil,
        userIsPremium: Bool? = nil
    ) -> Self {
        self.requestUsers(.init(
            requestId: requestId,
            userIsBot: userIsBot,
            userIsPremium: userIsPremium,
            maxQuantity: maxQuantity
        ))
    }

    /// Opens a chat picker; the selection arrives as a `chat_shared`
    /// service message carrying `requestId`.
    public func requestChat(_ request: KeyboardButtonRequestChat) -> Self {
        var copy = self
        copy.button.requestChat = request
        return copy
    }

    /// Opens a chat picker restricted to channels or to groups.
    public func requestChat(id requestId: Int64, isChannel: Bool) -> Self {
        self.requestChat(.init(requestId: requestId, chatIsChannel: isChannel))
    }

    /// Asks the user to create a poll and send it to the bot. Pass
    /// `"quiz"` or `"regular"` to force a kind.
    public func requestPoll(_ type: String? = nil) -> Self {
        var copy = self
        copy.button.requestPoll = .init(type: type)
        return copy
    }

    /// Asks the user to create a bot managed by this one.
    public func requestManagedBot(_ request: KeyboardButtonRequestManagedBot) -> Self {
        var copy = self
        copy.button.requestManagedBot = request
        return copy
    }

    /// Launches a Telegram Web App when pressed.
    public func webApp(url: String) -> Self {
        var copy = self
        copy.button.webApp = .init(url: url)
        return copy
    }

    /// Shows a custom emoji before the button label.
    public func icon(_ customEmojiId: String) -> Self {
        var copy = self
        copy.button.iconCustomEmojiId = customEmojiId
        return copy
    }

    /// Applies a button style (`danger`, `success`, `primary`).
    public func style(_ style: KeyboardButtonStyle) -> Self {
        var copy = self
        copy.button.style = style
        return copy
    }
}

/// One row of a reply keyboard.
public struct KeyRow: Sendable {
    public let buttons: [KeyButton]

    public init(@TelerouteKeyRowBuilder _ content: () -> [KeyButton]) {
        self.buttons = content()
    }
}

@resultBuilder
public enum TelerouteKeyRowBuilder {
    public static func buildBlock(_ buttons: [KeyButton]...) -> [KeyButton] {
        buttons.flatMap { $0 }
    }

    public static func buildExpression(_ button: KeyButton) -> [KeyButton] { [button] }
    public static func buildExpression(_ text: String) -> [KeyButton] { [KeyButton(text)] }
    public static func buildExpression(_ buttons: [KeyButton]) -> [KeyButton] { buttons }
    public static func buildOptional(_ buttons: [KeyButton]?) -> [KeyButton] { buttons ?? [] }
    public static func buildEither(first: [KeyButton]) -> [KeyButton] { first }
    public static func buildEither(second: [KeyButton]) -> [KeyButton] { second }
    public static func buildArray(_ rows: [[KeyButton]]) -> [KeyButton] { rows.flatMap { $0 } }
}

@resultBuilder
public enum TelerouteReplyKeyboardBuilder {
    public static func buildBlock(_ rows: [[KeyButton]]...) -> [[KeyButton]] {
        rows.flatMap { $0 }
    }

    public static func buildExpression(_ row: KeyRow) -> [[KeyButton]] { [row.buttons] }
    public static func buildExpression(_ button: KeyButton) -> [[KeyButton]] { [[button]] }
    public static func buildExpression(_ text: String) -> [[KeyButton]] { [[KeyButton(text)]] }
    public static func buildOptional(_ rows: [[KeyButton]]?) -> [[KeyButton]] { rows ?? [] }
    public static func buildEither(first: [[KeyButton]]) -> [[KeyButton]] { first }
    public static func buildEither(second: [[KeyButton]]) -> [[KeyButton]] { second }
    public static func buildArray(_ rows: [[[KeyButton]]]) -> [[KeyButton]] { rows.flatMap { $0 } }
}

public extension ReplyKeyboardMarkup {
    /// Builds a reply keyboard with the result-builder DSL:
    ///
    /// ```swift
    /// let keyboard = ReplyKeyboardMarkup(resize: true) {
    ///     KeyRow {
    ///         KeyButton("Share contact").requestContact()
    ///         "Cancel"
    ///     }
    /// }
    /// ```
    init(
        resize: Bool? = nil,
        oneTime: Bool? = nil,
        placeholder: String? = nil,
        selective: Bool? = nil,
        @TelerouteReplyKeyboardBuilder _ content: () -> [[KeyButton]]
    ) {
        self.init(
            keyboard: content().map { row in row.map(\.button) },
            resizeKeyboard: resize,
            oneTimeKeyboard: oneTime,
            inputFieldPlaceholder: placeholder,
            selective: selective
        )
    }
}
