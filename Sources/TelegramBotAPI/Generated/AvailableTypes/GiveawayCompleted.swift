// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a service message about the completion of a giveaway without public
/// winners.
public struct GiveawayCompleted: Codable, Hashable, Sendable {
    /// Number of winners in the giveaway
    public var winnerCount: Swift.Int64

    /// *Optional*. Number of undistributed prizes
    public var unclaimedPrizeCount: Swift.Int64?

    private var giveawayMessageBox: _IndirectBox<Message>?
    /// *Optional*. Message with the giveaway that was completed, if it wasn't deleted
    public var giveawayMessage: Message? {
        get { self.giveawayMessageBox?.value }
        set { self.giveawayMessageBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. *True*, if the giveaway is a Telegram Star giveaway. Otherwise, currently,
    /// the giveaway is a Telegram Premium giveaway.
    public var isStarGiveaway: Swift.Bool?

    public init(
        winnerCount: Swift.Int64,
        unclaimedPrizeCount: Swift.Int64? = nil,
        giveawayMessage: Message? = nil,
        isStarGiveaway: Swift.Bool? = nil
    ) {
        self.winnerCount = winnerCount
        self.unclaimedPrizeCount = unclaimedPrizeCount
        self.giveawayMessageBox = giveawayMessage.map(_IndirectBox.init)
        self.isStarGiveaway = isStarGiveaway
    }

    public enum CodingKeys: String, CodingKey {
        case winnerCount = "winner_count"
        case unclaimedPrizeCount = "unclaimed_prize_count"
        case giveawayMessageBox = "giveaway_message"
        case isStarGiveaway = "is_star_giveaway"
    }
}
