import Foundation
import SwiftTelegramBot

/// A typed callback button description rendered by `Teleroute` or a nested
/// `TelerouteRoutes` scope.
public struct TelerouteButton: Sendable {
    private enum Destination: Sendable {
        case callback(any TelerouteCallback)
        case registeredCallback(any TelerouteCallback, TelerouteCallbackRouteBinding)
        case raw(TGInlineKeyboardButton)
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
    public static func raw(_ button: TGInlineKeyboardButton) -> Self {
        .init(
            text: button.text,
            iconCustomEmojiId: button.iconCustomEmojiId,
            style: button.style,
            destination: .raw(button)
        )
    }

    func render(in routes: TelerouteRoutes) throws -> TGInlineKeyboardButton {
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
