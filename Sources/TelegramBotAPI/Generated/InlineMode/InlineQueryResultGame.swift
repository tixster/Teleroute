// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a ``Game``.
public struct InlineQueryResultGame: Codable, Hashable, Sendable {
    /// Type of the result, must be *game*
    public var type: InlineQueryResultKind

    /// Unique identifier for this result, 1-64 bytes
    public var id: Swift.String

    /// Short name of the game
    public var gameShortName: Swift.String

    /// *Optional*. Inline keyboard attached to the message
    public var replyMarkup: InlineKeyboardMarkup?

    public init(
        type: InlineQueryResultKind = .game,
        id: Swift.String,
        gameShortName: Swift.String,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) {
        self.type = type
        self.id = id
        self.gameShortName = gameShortName
        self.replyMarkup = replyMarkup
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case id
        case gameShortName = "game_short_name"
        case replyMarkup = "reply_markup"
    }
}
