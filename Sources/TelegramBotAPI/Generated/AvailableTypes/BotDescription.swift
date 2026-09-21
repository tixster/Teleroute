// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents the bot's description.
public struct BotDescription: Codable, Hashable, Sendable {
    /// The bot's description
    public var description: Swift.String

    public init(
        description: Swift.String
    ) {
        self.description = description
    }

    public enum CodingKeys: String, CodingKey {
        case description
    }
}
