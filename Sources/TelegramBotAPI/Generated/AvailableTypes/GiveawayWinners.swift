// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a message about the completion of a giveaway with public winners.
public struct GiveawayWinners: Codable, Hashable, Sendable {
    private var chatBox: _IndirectBox<Chat>
    /// The chat that created the giveaway
    public var chat: Chat {
        get { self.chatBox.value }
        set { self.chatBox = _IndirectBox(newValue) }
    }

    /// Identifier of the message with the giveaway in the chat
    public var giveawayMessageId: Swift.Int64

    /// Point in time (Unix timestamp) when winners of the giveaway were selected
    public var winnersSelectionDate: Swift.Int64

    /// Total number of winners in the giveaway
    public var winnerCount: Swift.Int64

    /// List of up to 100 winners of the giveaway
    public var winners: [User]

    /// *Optional*. The number of other chats the user had to join in order to be eligible for
    /// the giveaway
    public var additionalChatCount: Swift.Int64?

    /// *Optional*. The number of Telegram Stars that were split between giveaway winners; for
    /// Telegram Star giveaways only
    public var prizeStarCount: Swift.Int64?

    /// *Optional*. The number of months the Telegram Premium subscription won from the giveaway
    /// will be active for; for Telegram Premium giveaways only
    public var premiumSubscriptionMonthCount: Swift.Int64?

    /// *Optional*. Number of undistributed prizes
    public var unclaimedPrizeCount: Swift.Int64?

    /// *Optional*. *True*, if only users who had joined the chats after the giveaway started
    /// were eligible to win
    public var onlyNewMembers: Swift.Bool?

    /// *Optional*. *True*, if the giveaway was canceled because the payment for it was refunded
    public var wasRefunded: Swift.Bool?

    /// *Optional*. Description of additional giveaway prize
    public var prizeDescription: Swift.String?

    public init(
        chat: Chat,
        giveawayMessageId: Swift.Int64,
        winnersSelectionDate: Swift.Int64,
        winnerCount: Swift.Int64,
        winners: [User],
        additionalChatCount: Swift.Int64? = nil,
        prizeStarCount: Swift.Int64? = nil,
        premiumSubscriptionMonthCount: Swift.Int64? = nil,
        unclaimedPrizeCount: Swift.Int64? = nil,
        onlyNewMembers: Swift.Bool? = nil,
        wasRefunded: Swift.Bool? = nil,
        prizeDescription: Swift.String? = nil
    ) {
        self.chatBox = _IndirectBox(chat)
        self.giveawayMessageId = giveawayMessageId
        self.winnersSelectionDate = winnersSelectionDate
        self.winnerCount = winnerCount
        self.winners = winners
        self.additionalChatCount = additionalChatCount
        self.prizeStarCount = prizeStarCount
        self.premiumSubscriptionMonthCount = premiumSubscriptionMonthCount
        self.unclaimedPrizeCount = unclaimedPrizeCount
        self.onlyNewMembers = onlyNewMembers
        self.wasRefunded = wasRefunded
        self.prizeDescription = prizeDescription
    }

    public enum CodingKeys: String, CodingKey {
        case chatBox = "chat"
        case giveawayMessageId = "giveaway_message_id"
        case winnersSelectionDate = "winners_selection_date"
        case winnerCount = "winner_count"
        case winners
        case additionalChatCount = "additional_chat_count"
        case prizeStarCount = "prize_star_count"
        case premiumSubscriptionMonthCount = "premium_subscription_month_count"
        case unclaimedPrizeCount = "unclaimed_prize_count"
        case onlyNewMembers = "only_new_members"
        case wasRefunded = "was_refunded"
        case prizeDescription = "prize_description"
    }
}
