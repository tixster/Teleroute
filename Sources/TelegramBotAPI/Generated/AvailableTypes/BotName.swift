// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents the bot's name.
public struct BotName: Codable, Hashable, Sendable {
    /// The bot's name
    public var name: Swift.String

    public init(
        name: Swift.String
    ) {
        self.name = name
    }

    public enum CodingKeys: String, CodingKey {
        case name
    }
}
