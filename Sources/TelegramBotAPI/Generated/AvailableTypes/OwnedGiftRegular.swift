// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a regular gift owned by a user or a chat.
public struct OwnedGiftRegular: Codable, Hashable, Sendable {
    /// Type of the gift, always “regular”
    public var type: OwnedGiftKind

    private var giftBox: _IndirectBox<Gift>
    /// Information about the regular gift
    public var gift: Gift {
        get { self.giftBox.value }
        set { self.giftBox = _IndirectBox(newValue) }
    }

    /// *Optional*. Unique identifier of the gift for the bot; for gifts received on behalf of
    /// business accounts only
    public var ownedGiftId: Swift.String?

    private var senderUserBox: _IndirectBox<User>?
    /// *Optional*. Sender of the gift if it is a known user
    public var senderUser: User? {
        get { self.senderUserBox?.value }
        set { self.senderUserBox = newValue.map(_IndirectBox.init) }
    }

    /// Date the gift was sent in Unix time
    public var sendDate: Swift.Int64

    /// *Optional*. Text of the message that was added to the gift
    public var text: Swift.String?

    /// *Optional*. Special entities that appear in the text
    public var entities: [MessageEntity]?

    /// *Optional*. *True*, if the sender and gift text are shown only to the gift receiver;
    /// otherwise, everyone will be able to see them
    public var isPrivate: Swift.Bool?

    /// *Optional*. *True*, if the gift is displayed on the account's profile page; for gifts
    /// received on behalf of business accounts only
    public var isSaved: Swift.Bool?

    /// *Optional*. *True*, if the gift can be upgraded to a unique gift; for gifts received on
    /// behalf of business accounts only
    public var canBeUpgraded: Swift.Bool?

    /// *Optional*. *True*, if the gift was refunded and isn't available anymore
    public var wasRefunded: Swift.Bool?

    /// *Optional*. Number of Telegram Stars that can be claimed by the receiver instead of the
    /// gift; omitted if the gift cannot be converted to Telegram Stars; for gifts received on
    /// behalf of business accounts only
    public var convertStarCount: Swift.Int64?

    /// *Optional*. Number of Telegram Stars that were paid for the ability to upgrade the gift
    public var prepaidUpgradeStarCount: Swift.Int64?

    /// *Optional*. *True*, if the gift's upgrade was purchased after the gift was sent; for
    /// gifts received on behalf of business accounts only
    public var isUpgradeSeparate: Swift.Bool?

    /// *Optional*. Unique number reserved for this gift when upgraded. See the *number* field
    /// in ``UniqueGift``.
    public var uniqueGiftNumber: Swift.Int64?

    public init(
        type: OwnedGiftKind = .regular,
        gift: Gift,
        ownedGiftId: Swift.String? = nil,
        senderUser: User? = nil,
        sendDate: Swift.Int64,
        text: Swift.String? = nil,
        entities: [MessageEntity]? = nil,
        isPrivate: Swift.Bool? = nil,
        isSaved: Swift.Bool? = nil,
        canBeUpgraded: Swift.Bool? = nil,
        wasRefunded: Swift.Bool? = nil,
        convertStarCount: Swift.Int64? = nil,
        prepaidUpgradeStarCount: Swift.Int64? = nil,
        isUpgradeSeparate: Swift.Bool? = nil,
        uniqueGiftNumber: Swift.Int64? = nil
    ) {
        self.type = type
        self.giftBox = _IndirectBox(gift)
        self.ownedGiftId = ownedGiftId
        self.senderUserBox = senderUser.map(_IndirectBox.init)
        self.sendDate = sendDate
        self.text = text
        self.entities = entities
        self.isPrivate = isPrivate
        self.isSaved = isSaved
        self.canBeUpgraded = canBeUpgraded
        self.wasRefunded = wasRefunded
        self.convertStarCount = convertStarCount
        self.prepaidUpgradeStarCount = prepaidUpgradeStarCount
        self.isUpgradeSeparate = isUpgradeSeparate
        self.uniqueGiftNumber = uniqueGiftNumber
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case giftBox = "gift"
        case ownedGiftId = "owned_gift_id"
        case senderUserBox = "sender_user"
        case sendDate = "send_date"
        case text
        case entities
        case isPrivate = "is_private"
        case isSaved = "is_saved"
        case canBeUpgraded = "can_be_upgraded"
        case wasRefunded = "was_refunded"
        case convertStarCount = "convert_star_count"
        case prepaidUpgradeStarCount = "prepaid_upgrade_star_count"
        case isUpgradeSeparate = "is_upgrade_separate"
        case uniqueGiftNumber = "unique_gift_number"
    }
}
