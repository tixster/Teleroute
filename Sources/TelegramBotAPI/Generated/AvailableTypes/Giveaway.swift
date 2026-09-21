// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a message about a scheduled giveaway.
public struct Giveaway: Codable, Hashable, Sendable {
    /// The list of chats which the user must join to participate in the giveaway
    public var chats: [Chat]

    /// Point in time (Unix timestamp) when winners of the giveaway will be selected
    public var winnersSelectionDate: Swift.Int64

    /// The number of users which are supposed to be selected as winners of the giveaway
    public var winnerCount: Swift.Int64

    /// *Optional*. *True*, if only users who join the chats after the giveaway started should
    /// be eligible to win
    public var onlyNewMembers: Swift.Bool?

    /// *Optional*. *True*, if the list of giveaway winners will be visible to everyone
    public var hasPublicWinners: Swift.Bool?

    /// *Optional*. Description of additional giveaway prize
    public var prizeDescription: Swift.String?

    /// *Optional*. A list of two-letter [ISO 3166-1
    /// alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country codes indicating the
    /// countries from which eligible users for the giveaway must come. If empty, then all users
    /// can participate in the giveaway. Users with a phone number that was bought on Fragment
    /// can always participate in giveaways.
    public var countryCodes: [Swift.String]?

    /// *Optional*. The number of Telegram Stars to be split between giveaway winners; for
    /// Telegram Star giveaways only
    public var prizeStarCount: Swift.Int64?

    /// *Optional*. The number of months the Telegram Premium subscription won from the giveaway
    /// will be active for; for Telegram Premium giveaways only
    public var premiumSubscriptionMonthCount: Swift.Int64?

    public init(
        chats: [Chat],
        winnersSelectionDate: Swift.Int64,
        winnerCount: Swift.Int64,
        onlyNewMembers: Swift.Bool? = nil,
        hasPublicWinners: Swift.Bool? = nil,
        prizeDescription: Swift.String? = nil,
        countryCodes: [Swift.String]? = nil,
        prizeStarCount: Swift.Int64? = nil,
        premiumSubscriptionMonthCount: Swift.Int64? = nil
    ) {
        self.chats = chats
        self.winnersSelectionDate = winnersSelectionDate
        self.winnerCount = winnerCount
        self.onlyNewMembers = onlyNewMembers
        self.hasPublicWinners = hasPublicWinners
        self.prizeDescription = prizeDescription
        self.countryCodes = countryCodes
        self.prizeStarCount = prizeStarCount
        self.premiumSubscriptionMonthCount = premiumSubscriptionMonthCount
    }

    public enum CodingKeys: String, CodingKey {
        case chats
        case winnersSelectionDate = "winners_selection_date"
        case winnerCount = "winner_count"
        case onlyNewMembers = "only_new_members"
        case hasPublicWinners = "has_public_winners"
        case prizeDescription = "prize_description"
        case countryCodes = "country_codes"
        case prizeStarCount = "prize_star_count"
        case premiumSubscriptionMonthCount = "premium_subscription_month_count"
    }
}
