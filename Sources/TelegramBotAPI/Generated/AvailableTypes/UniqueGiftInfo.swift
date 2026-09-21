// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a service message about a unique gift that was sent or received.
public struct UniqueGiftInfo: Codable, Hashable, Sendable {
    private var giftBox: _IndirectBox<UniqueGift>
    /// Information about the gift
    public var gift: UniqueGift {
        get { self.giftBox.value }
        set { self.giftBox = _IndirectBox(newValue) }
    }

    /// Origin of the gift. Currently, either “upgrade” for gifts upgraded from regular gifts,
    /// “transfer” for gifts transferred from other users or channels, “resale” for gifts bought
    /// from other users, “gifted_upgrade” for upgrades purchased after the gift was sent, or
    /// “offer” for gifts bought or sold through gift purchase offers.
    public var origin: Swift.String

    /// *Optional*. Text of the message that was added to the gift
    public var text: Swift.String?

    /// *Optional*. Special entities that appear in the text
    public var entities: [MessageEntity]?

    /// *Optional*. *True*, if the sender and gift text are shown only to the gift receiver;
    /// otherwise, everyone will be able to see them
    public var isPrivate: Swift.Bool?

    /// *Optional*. For gifts bought from other users, the currency in which the payment for the
    /// gift was done. Currently, one of “XTR” for Telegram Stars or “TON” for TON grams.
    public var lastResaleCurrency: SuggestedPostPaidCurrency?

    /// *Optional*. For gifts bought from other users, the price paid for the gift in either
    /// Telegram Stars or nanograms
    public var lastResaleAmount: Swift.Int64?

    /// *Optional*. Unique identifier of the received gift for the bot; only present for gifts
    /// received on behalf of business accounts
    public var ownedGiftId: Swift.String?

    /// *Optional*. Number of Telegram Stars that must be paid to transfer the gift; omitted if
    /// the bot cannot transfer the gift
    public var transferStarCount: Swift.Int64?

    /// *Optional*. Point in time (Unix timestamp) when the gift can be transferred. If it is in
    /// the past, then the gift can be transferred now.
    public var nextTransferDate: Swift.Int64?

    public init(
        gift: UniqueGift,
        origin: Swift.String,
        text: Swift.String? = nil,
        entities: [MessageEntity]? = nil,
        isPrivate: Swift.Bool? = nil,
        lastResaleCurrency: SuggestedPostPaidCurrency? = nil,
        lastResaleAmount: Swift.Int64? = nil,
        ownedGiftId: Swift.String? = nil,
        transferStarCount: Swift.Int64? = nil,
        nextTransferDate: Swift.Int64? = nil
    ) {
        self.giftBox = _IndirectBox(gift)
        self.origin = origin
        self.text = text
        self.entities = entities
        self.isPrivate = isPrivate
        self.lastResaleCurrency = lastResaleCurrency
        self.lastResaleAmount = lastResaleAmount
        self.ownedGiftId = ownedGiftId
        self.transferStarCount = transferStarCount
        self.nextTransferDate = nextTransferDate
    }

    public enum CodingKeys: String, CodingKey {
        case giftBox = "gift"
        case origin
        case text
        case entities
        case isPrivate = "is_private"
        case lastResaleCurrency = "last_resale_currency"
        case lastResaleAmount = "last_resale_amount"
        case ownedGiftId = "owned_gift_id"
        case transferStarCount = "transfer_star_count"
        case nextTransferDate = "next_transfer_date"
    }
}
