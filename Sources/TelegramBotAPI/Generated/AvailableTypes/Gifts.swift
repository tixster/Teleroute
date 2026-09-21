// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represent a list of gifts.
public struct Gifts: Codable, Hashable, Sendable {
    /// The list of gifts
    public var gifts: [Gift]

    public init(
        gifts: [Gift]
    ) {
        self.gifts = gifts
    }

    public enum CodingKeys: String, CodingKey {
        case gifts
    }
}
