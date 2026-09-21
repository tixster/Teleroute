// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The boost was obtained by the creation of a Telegram Premium or a Telegram Star giveaway.
/// This boosts the chat 4 times for the duration of the corresponding Telegram Premium
/// subscription for Telegram Premium giveaways and *prize_star_count* / 500 times for one year
/// for Telegram Star giveaways.
public struct ChatBoostSourceGiveaway: Codable, Hashable, Sendable {
    /// Source of the boost, always “giveaway”
    public var source: ChatBoostSourceKind

    /// Identifier of a message in the chat with the giveaway; the message could have been
    /// deleted already. May be 0 if the message isn't sent yet.
    public var giveawayMessageId: Swift.Int64

    private var userBox: _IndirectBox<User>?
    /// *Optional*. User that won the prize in the giveaway if any; for Telegram Premium
    /// giveaways only
    public var user: User? {
        get { self.userBox?.value }
        set { self.userBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. The number of Telegram Stars to be split between giveaway winners; for
    /// Telegram Star giveaways only
    public var prizeStarCount: Swift.Int64?

    /// *Optional*. *True*, if the giveaway was completed, but there was no user to win the
    /// prize
    public var isUnclaimed: Swift.Bool?

    public init(
        source: ChatBoostSourceKind = .giveaway,
        giveawayMessageId: Swift.Int64,
        user: User? = nil,
        prizeStarCount: Swift.Int64? = nil,
        isUnclaimed: Swift.Bool? = nil
    ) {
        self.source = source
        self.giveawayMessageId = giveawayMessageId
        self.userBox = user.map(_IndirectBox.init)
        self.prizeStarCount = prizeStarCount
        self.isUnclaimed = isUnclaimed
    }

    public enum CodingKeys: String, CodingKey {
        case source
        case giveawayMessageId = "giveaway_message_id"
        case userBox = "user"
        case prizeStarCount = "prize_star_count"
        case isUnclaimed = "is_unclaimed"
    }
}
