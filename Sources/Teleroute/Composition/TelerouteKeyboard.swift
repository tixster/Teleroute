import Foundation
import TelegramBotAPI

/// Everything a button needs at render time beyond its route scope: where to
/// park an inline handler, and who the keyboard is being rendered for.
///
/// Only buttons carrying an inline handler need it; the rest render without.
struct TelerouteRenderContext: Sendable {
    let inlineActions: TelerouteInlineActionStore?
    let chatId: Int64?
    let userId: Int64?
}

/// A typed callback button description rendered by a ``Teleroute`` or
/// nested ``TelerouteRouterGroup``.
public struct TelerouteButton: Sendable {
    private enum Destination: Sendable {
        case callback(any TelerouteCallback)
        case registeredCallback(any TelerouteCallback, TelerouteCallbackRouteBinding)
        case inlineAction(
            TelerouteInlineAction,
            TelerouteInlineActionScope,
            TelerouteButtonCompletion
        )
        case raw(InlineKeyboardButton)
    }

    private let text: String
    private let iconCustomEmojiId: String?
    private let style: KeyboardButtonStyle?
    private let destination: Destination

    private init(
        text: String,
        iconCustomEmojiId: String?,
        style: KeyboardButtonStyle?,
        destination: Destination
    ) {
        self.text = text
        self.iconCustomEmojiId = iconCustomEmojiId
        self.style = style
        self.destination = destination
    }

    static func callback(
        _ text: String,
        _ callback: any TelerouteCallback,
        iconCustomEmojiId: String? = nil,
        style: KeyboardButtonStyle? = nil
    ) -> Self {
        .init(
            text: text,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style,
            destination: .callback(callback)
        )
    }

    static func callback(
        _ text: String,
        _ callback: any TelerouteCallback,
        binding: TelerouteCallbackRouteBinding,
        iconCustomEmojiId: String? = nil,
        style: KeyboardButtonStyle? = nil
    ) -> Self {
        .init(
            text: text,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style,
            destination: .registeredCallback(callback, binding)
        )
    }

    /// Includes an already-created Telegram button unchanged.
    public static func raw(_ button: InlineKeyboardButton) -> Self {
        .init(
            text: button.text,
            iconCustomEmojiId: button.iconCustomEmojiId,
            style: button.style,
            destination: .raw(button)
        )
    }

    /// A button opening a URL.
    public static func url(_ text: String, _ url: String) -> Self {
        .raw(.init(text: text, url: url))
    }

    /// A button launching a Telegram Web App.
    public static func webApp(_ text: String, url: String) -> Self {
        .raw(.init(text: text, webApp: .init(url: url)))
    }

    /// A button inserting an inline query in another (or the current) chat.
    public static func switchInlineQuery(
        _ text: String,
        query: String = "",
        currentChat: Bool = false
    ) -> Self {
        currentChat
            ? .raw(.init(text: text, switchInlineQueryCurrentChat: query))
            : .raw(.init(text: text, switchInlineQuery: query))
    }

    /// A button copying the given text to the user's clipboard.
    public static func copyText(_ text: String, copy: String) -> Self {
        .raw(.init(text: text, copyText: .init(text: copy)))
    }

    /// A pay button (must be the first button of an invoice keyboard).
    public static func pay(_ text: String) -> Self {
        .raw(.init(text: text, pay: true))
    }

    /// A Telegram Login widget button.
    public static func loginUrl(_ text: String, _ loginUrl: LoginUrl) -> Self {
        .raw(.init(text: text, loginUrl: loginUrl))
    }

    /// A button inserting an inline query in a chat the user picks, limited
    /// to the chat types described by `chosenChat`.
    public static func switchInlineQuery(
        _ text: String,
        chosenChat: SwitchInlineQueryChosenChat
    ) -> Self {
        .raw(.init(text: text, switchInlineQueryChosenChat: chosenChat))
    }

    /// A button launching a Telegram game (must be the first button of the
    /// first row).
    public static func callbackGame(_ text: String) -> Self {
        .raw(.init(text: text, callbackGame: .init()))
    }

    /// A greyed-out button that does nothing when pressed — useful as a
    /// label inside a keyboard, such as a page counter.
    public static func disabled(_ text: String) -> Self {
        .raw(.init(text: text, disabled: .init()))
    }

    // MARK: - Initializers

    /// A button dispatching to a typed callback route.
    ///
    /// ```swift
    /// Row {
    ///     TelerouteButton("Next ▶︎") { OrderPage(id: "7", page: 1) }
    /// }
    /// ```
    ///
    /// The route is resolved when the keyboard renders: the value's own path
    /// is matched against every registered callback route, so a callback
    /// registered inside a group works from a handler's `keyboard { }` too.
    public init<Callback: TelerouteCallback>(
        _ text: String,
        _ callback: () -> Callback
    ) {
        self = .callback(text, callback())
    }

    /// A button opening a URL.
    public init(_ text: String, url: String) {
        self = .url(text, url)
    }

    /// A button launching a Telegram Web App.
    public init(_ text: String, webApp url: String) {
        self = .webApp(text, url: url)
    }

    /// A button copying text to the user's clipboard.
    public init(_ text: String, copy: String) {
        self = .copyText(text, copy: copy)
    }

    /// A button inserting an inline query in another (or the current) chat.
    public init(
        _ text: String,
        switchInlineQuery query: String,
        currentChat: Bool = false
    ) {
        self = .switchInlineQuery(text, query: query, currentChat: currentChat)
    }

    /// A button whose handler is written right here, with no callback type
    /// and no route registration.
    ///
    /// ```swift
    /// Reply("Order 7").keyboard {
    ///     Row {
    ///         TelerouteButton("Approve") { context in
    ///             try await orders.approve(7)
    ///             return .edit("Order 7 approved")
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// The closure receives the context of the **press**. A context captured
    /// from the surrounding handler belongs to the older update, so answering
    /// through it throws ``TelerouteError/callbackQueryMissing`` — reply
    /// through the parameter instead.
    ///
    /// Handlers live in memory, so they do not survive a restart and are not
    /// visible to other instances of the bot; see ``TelerouteInlineActionPolicy``.
    ///
    /// - Parameters:
    ///   - text: Button label.
    ///   - scope: Who may press it. Defaults to the user the keyboard was
    ///     rendered for, so a bystander in a group cannot act on it.
    ///   - onSuccess: What to do with the keyboard once the handler returns
    ///     without throwing — `.removeButton` takes this button away,
    ///     `.removeKeyboard` takes all of them. Skipped when the handler's own
    ///     response edits the message, since that already sets the keyboard.
    ///   - action: Runs when the button is pressed.
    public init(
        _ text: String,
        scope: TelerouteInlineActionScope = .user,
        onSuccess: TelerouteButtonCompletion = .keep,
        action: @escaping @Sendable (TelerouteContext) async throws -> some TelerouteResponseGenerator
    ) {
        self.init(
            text: text,
            iconCustomEmojiId: nil,
            style: nil,
            destination: .inlineAction(
                { try await action($0).makeResponse() },
                scope,
                onSuccess
            )
        )
    }

    /// A button whose handler needs nothing from the press itself.
    ///
    /// ```swift
    /// TelerouteButton("Cancel") { .edit("Cancelled") }
    /// ```
    public init(
        _ text: String,
        scope: TelerouteInlineActionScope = .user,
        onSuccess: TelerouteButtonCompletion = .keep,
        action: @escaping @Sendable () async throws -> some TelerouteResponseGenerator
    ) {
        self.init(
            text,
            scope: scope,
            onSuccess: onSuccess,
            action: { _ in try await action() }
        )
    }

    /// A button of one of the parameterless kinds.
    public init(_ text: String, _ kind: Kind) {
        self = switch kind {
        case .disabled: .disabled(text)
        case .pay: .pay(text)
        case .callbackGame: .callbackGame(text)
        }
    }

    // MARK: - Modifiers

    /// Applies a button style (`danger`, `success`, `primary`).
    public func style(_ style: KeyboardButtonStyle?) -> Self {
        .init(
            text: self.text,
            iconCustomEmojiId: self.iconCustomEmojiId,
            style: style,
            destination: self.destination
        )
    }

    /// Shows a custom emoji before the button label.
    public func icon(_ customEmojiId: String?) -> Self {
        .init(
            text: self.text,
            iconCustomEmojiId: customEmojiId,
            style: self.style,
            destination: self.destination
        )
    }

    func render(
        in routes: TelerouteRoutes,
        context: TelerouteRenderContext? = nil
    ) throws -> InlineKeyboardButton {
        switch self.destination {
        case let .inlineAction(action, scope, completion):
            return .init(
                text: self.text,
                iconCustomEmojiId: self.iconCustomEmojiId,
                style: self.style,
                callbackData: try Self.registerInlineAction(
                    action,
                    scope: scope,
                    completion: completion,
                    context: context
                )
            )
        default:
            break
        }

        return switch self.destination {
        case let .callback(callback):
            .init(
                text: self.text,
                iconCustomEmojiId: self.iconCustomEmojiId,
                style: self.style,
                callbackData: try routes.registeredCallbackData(for: callback)
            )
        case let .registeredCallback(callback, binding):
            .init(
                text: self.text,
                iconCustomEmojiId: self.iconCustomEmojiId,
                style: self.style,
                callbackData: try binding.callbackData(
                    for: callback,
                    renderedBy: routes
                )
            )
        case let .raw(button):
            // The outer text/style/icon win: `raw(_:)` seeds them from the
            // button itself, so this is a no-op until a chainable modifier
            // such as `style(_:)` changes one of them.
            {
                var copy = button
                copy.text = self.text
                copy.iconCustomEmojiId = self.iconCustomEmojiId
                copy.style = self.style
                return copy
            }()

        case .inlineAction:
            // Handled above; `switch` needs the case to stay exhaustive.
            preconditionFailure("inline actions are rendered before this switch")
        }
    }

    private static func registerInlineAction(
        _ action: @escaping TelerouteInlineAction,
        scope: TelerouteInlineActionScope,
        completion: TelerouteButtonCompletion,
        context: TelerouteRenderContext?
    ) throws -> String {
        guard let context else {
            throw TelerouteError.inlineActionContextMissing
        }
        guard let store = context.inlineActions else {
            throw TelerouteError.inlineActionsDisabled
        }
        let id = store.insert(
            action: action,
            scope: scope,
            completion: completion,
            chatId: context.chatId,
            userId: context.userId
        )
        return try TelerouteCallbackPattern(prefix: [], path: telerouteInlineActionPath)
            .render(parameters: ["id": id])
    }
}

public extension TelerouteButton {
    /// A button kind that carries no payload beyond its label.
    enum Kind: Sendable {
        /// A greyed-out button that does nothing when pressed.
        case disabled
        /// A pay button; must be the first button of an invoice keyboard.
        case pay
        /// A game button; must be the first button of the first row.
        case callbackGame
    }
}

public extension TelerouteCallback {
    /// Creates a button validated against the scope that later renders it.
    func button(
        _ text: String,
        iconCustomEmojiId: String? = nil,
        style: KeyboardButtonStyle? = nil
    ) -> TelerouteButton {
        .callback(
            text,
            self,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style
        )
    }
}

/// Pagination helpers for callback keyboards.
public enum TeleroutePagination {
    /// Builds a typed previous/next callback-button row for a zero-based page index.
    public static func navigationRow<Callback: TelerouteCallback>(
        _ route: TelerouteCallbackRoute<Callback>,
        page: Int,
        pageCount: Int,
        previousLabel: String = "◀︎ Prev",
        nextLabel: String = "Next ▶︎",
        callback: (Int) -> Callback
    ) -> [TelerouteButton] {
        var buttons: [TelerouteButton] = []
        if page > 0 {
            buttons.append(
                route.button(callback(page - 1), previousLabel)
            )
        }
        if page < pageCount - 1 {
            buttons.append(
                route.button(callback(page + 1), nextLabel)
            )
        }
        return buttons
    }
}
