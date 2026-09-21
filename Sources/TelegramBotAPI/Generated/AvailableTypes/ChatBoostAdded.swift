// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a service message about a user boosting a chat.
public struct ChatBoostAdded: Codable, Hashable, Sendable {
    /// Number of boosts added by the user
    public var boostCount: Swift.Int64

    public init(
        boostCount: Swift.Int64
    ) {
        self.boostCount = boostCount
    }

    public enum CodingKeys: String, CodingKey {
        case boostCount = "boost_count"
    }
}
