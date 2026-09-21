// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a service message about a change in the price of paid messages within a chat.
public struct PaidMessagePriceChanged: Codable, Hashable, Sendable {
    /// The new number of Telegram Stars that must be paid by non-administrator users of the
    /// supergroup chat for each sent message
    public var paidMessageStarCount: Swift.Int64

    public init(
        paidMessageStarCount: Swift.Int64
    ) {
        self.paidMessageStarCount = paidMessageStarCount
    }

    public enum CodingKeys: String, CodingKey {
        case paidMessageStarCount = "paid_message_star_count"
    }
}
