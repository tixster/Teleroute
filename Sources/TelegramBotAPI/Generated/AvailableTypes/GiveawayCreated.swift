// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a service message about the creation of a scheduled giveaway.
public struct GiveawayCreated: Codable, Hashable, Sendable {
    /// *Optional*. The number of Telegram Stars to be split between giveaway winners; for
    /// Telegram Star giveaways only
    public var prizeStarCount: Swift.Int64?

    public init(
        prizeStarCount: Swift.Int64? = nil
    ) {
        self.prizeStarCount = prizeStarCount
    }

    public enum CodingKeys: String, CodingKey {
        case prizeStarCount = "prize_star_count"
    }
}
