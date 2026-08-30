import Foundation

/// A declarative Telegram action returned by a route handler or typed
/// middleware.
///
/// `command` and `callback` handlers return this type. Use `onCommand` or
/// `onCallback` when a handler needs arbitrary direct Telegram operations.
public indirect enum TelerouteResponse: Sendable {
    /// Completes the route without sending an additional Telegram request.
    case none
    /// Replies to the current message, or sends to the resolved chat.
    case reply(
        String,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    )
    /// Sends a message to an explicit chat or the chat resolved from the update.
    case send(
        String,
        to: Int64? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    )
    /// Edits the message associated with the current update.
    case edit(
        String,
        parseMode: ParseMode? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil
    )
    /// Answers the current callback query.
    case answerCallback(
        String? = nil,
        showAlert: Bool? = nil,
        url: String? = nil,
        cacheTime: Int? = nil
    )
    /// Executes multiple responses in their declared order.
    case sequence([TelerouteResponse])

    func execute(in context: TelerouteContext) async throws {
        switch self {
        case .none:
            return

        case let .reply(text, parseMode, replyMarkup):
            try await context.reply(
                text,
                parseMode: parseMode,
                replyMarkup: replyMarkup
            )

        case let .send(text, chatID, parseMode, replyMarkup):
            try await context.send(
                text,
                to: chatID,
                parseMode: parseMode,
                replyMarkup: replyMarkup
            )

        case let .edit(text, parseMode, replyMarkup):
            try await context.edit(
                text,
                parseMode: parseMode,
                replyMarkup: replyMarkup
            )

        case let .answerCallback(text, showAlert, url, cacheTime):
            try await context.answerCallbackQuery(
                text,
                showAlert: showAlert,
                url: url,
                cacheTime: cacheTime
            )

        case let .sequence(responses):
            for response in responses {
                try await response.execute(in: context)
            }
        }
    }
}
