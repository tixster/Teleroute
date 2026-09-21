// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents the bot's short description.
public struct BotShortDescription: Codable, Hashable, Sendable {
    /// The bot's short description
    public var shortDescription: Swift.String

    public init(
        shortDescription: Swift.String
    ) {
        self.shortDescription = shortDescription
    }

    public enum CodingKeys: String, CodingKey {
        case shortDescription = "short_description"
    }
}
