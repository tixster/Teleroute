// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a list of boosts added to a chat by a user.
public struct UserChatBoosts: Codable, Hashable, Sendable {
    /// The list of boosts added to the chat by the user
    public var boosts: [ChatBoost]

    public init(
        boosts: [ChatBoost]
    ) {
        self.boosts = boosts
    }

    public enum CodingKeys: String, CodingKey {
        case boosts
    }
}
