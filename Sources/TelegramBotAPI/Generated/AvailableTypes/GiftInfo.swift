// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a service message about a regular gift that was sent or received.
public struct GiftInfo: Codable, Hashable, Sendable {
    private var giftBox: _IndirectBox<Gift>
    /// Information about the gift
    public var gift: Gift {
        get { self.giftBox.value }
        set { self.giftBox = _IndirectBox(newValue) }
    }

    /// *Optional*. Unique identifier of the received gift for the bot; only present for gifts
    /// received on behalf of business accounts
    public var ownedGiftId: Swift.String?

    /// *Optional*. Number of Telegram Stars that can be claimed by the receiver by converting
    /// the gift; omitted if conversion to Telegram Stars is impossible
    public var convertStarCount: Swift.Int64?

    /// *Optional*. Number of Telegram Stars that were prepaid for the ability to upgrade the
    /// gift
    public var prepaidUpgradeStarCount: Swift.Int64?

    /// *Optional*. *True*, if the gift's upgrade was purchased after the gift was sent
    public var isUpgradeSeparate: Swift.Bool?

    /// *Optional*. *True*, if the gift can be upgraded to a unique gift
    public var canBeUpgraded: Swift.Bool?

    /// *Optional*. Text of the message that was added to the gift
    public var text: Swift.String?

    /// *Optional*. Special entities that appear in the text
    public var entities: [MessageEntity]?

    /// *Optional*. *True*, if the sender and gift text are shown only to the gift receiver;
    /// otherwise, everyone will be able to see them
    public var isPrivate: Swift.Bool?

    /// *Optional*. Unique number reserved for this gift when upgraded. See the *number* field
    /// in ``UniqueGift``.
    public var uniqueGiftNumber: Swift.Int64?

    public init(
        gift: Gift,
        ownedGiftId: Swift.String? = nil,
        convertStarCount: Swift.Int64? = nil,
        prepaidUpgradeStarCount: Swift.Int64? = nil,
        isUpgradeSeparate: Swift.Bool? = nil,
        canBeUpgraded: Swift.Bool? = nil,
        text: Swift.String? = nil,
        entities: [MessageEntity]? = nil,
        isPrivate: Swift.Bool? = nil,
        uniqueGiftNumber: Swift.Int64? = nil
    ) {
        self.giftBox = _IndirectBox(gift)
        self.ownedGiftId = ownedGiftId
        self.convertStarCount = convertStarCount
        self.prepaidUpgradeStarCount = prepaidUpgradeStarCount
        self.isUpgradeSeparate = isUpgradeSeparate
        self.canBeUpgraded = canBeUpgraded
        self.text = text
        self.entities = entities
        self.isPrivate = isPrivate
        self.uniqueGiftNumber = uniqueGiftNumber
    }

    public enum CodingKeys: String, CodingKey {
        case giftBox = "gift"
        case ownedGiftId = "owned_gift_id"
        case convertStarCount = "convert_star_count"
        case prepaidUpgradeStarCount = "prepaid_upgrade_star_count"
        case isUpgradeSeparate = "is_upgrade_separate"
        case canBeUpgraded = "can_be_upgraded"
        case text
        case entities
        case isPrivate = "is_private"
        case uniqueGiftNumber = "unique_gift_number"
    }
}
