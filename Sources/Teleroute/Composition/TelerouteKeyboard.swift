import Foundation
import TelegramBotAPI

/// A typed callback button description rendered by a ``Teleroute`` or
/// nested ``TelerouteRouterGroup``.
public struct TelerouteButton: Sendable {
    private enum Destination: Sendable {
        case callback(any TelerouteCallback)
        case registeredCallback(any TelerouteCallback, TelerouteCallbackRouteBinding)
        case raw(InlineKeyboardButton)
    }

    private let text: String
    private let iconCustomEmojiId: String?
    private let style: String?
    private let destination: Destination

    private init(
        text: String,
        iconCustomEmojiId: String?,
        style: String?,
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
        style: String? = nil
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
        style: String? = nil
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
    public static func loginUrl(_ text: String, _ loginUrl: Components.Schemas.LoginUrl) -> Self {
        .raw(.init(text: text, loginUrl: loginUrl))
    }

    func render(in routes: TelerouteRoutes) throws -> InlineKeyboardButton {
        switch self.destination {
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
            button
        }
    }
}

public extension TelerouteCallback {
    /// Creates a button validated against the scope that later renders it.
    func button(
        _ text: String,
        iconCustomEmojiId: String? = nil,
        style: String? = nil
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
