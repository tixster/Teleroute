// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a unique gift received and owned by a user or a chat.
public struct OwnedGiftUnique: Codable, Hashable, Sendable {
    /// Type of the gift, always “unique”
    public var type: OwnedGiftKind

    private var giftBox: _IndirectBox<UniqueGift>
    /// Information about the unique gift
    public var gift: UniqueGift {
        get { self.giftBox.value }
        set { self.giftBox = _IndirectBox(newValue) }
    }

    /// *Optional*. Unique identifier of the received gift for the bot; for gifts received on
    /// behalf of business accounts only
    public var ownedGiftId: Swift.String?

    private var senderUserBox: _IndirectBox<User>?
    /// *Optional*. Sender of the gift if it is a known user
    public var senderUser: User? {
        get { self.senderUserBox?.value }
        set { self.senderUserBox = newValue.map(_IndirectBox.init) }
    }

    /// Date the gift was sent in Unix time
    public var sendDate: Swift.Int64

    /// *Optional*. *True*, if the gift is displayed on the account's profile page; for gifts
    /// received on behalf of business accounts only
    public var isSaved: Swift.Bool?

    /// *Optional*. *True*, if the gift can be transferred to another owner; for gifts received
    /// on behalf of business accounts only
    public var canBeTransferred: Swift.Bool?

    /// *Optional*. Number of Telegram Stars that must be paid to transfer the gift; omitted if
    /// the bot cannot transfer the gift
    public var transferStarCount: Swift.Int64?

    /// *Optional*. Point in time (Unix timestamp) when the gift can be transferred. If it is in
    /// the past, then the gift can be transferred now.
    public var nextTransferDate: Swift.Int64?

    public init(
        type: OwnedGiftKind = .unique,
        gift: UniqueGift,
        ownedGiftId: Swift.String? = nil,
        senderUser: User? = nil,
        sendDate: Swift.Int64,
        isSaved: Swift.Bool? = nil,
        canBeTransferred: Swift.Bool? = nil,
        transferStarCount: Swift.Int64? = nil,
        nextTransferDate: Swift.Int64? = nil
    ) {
        self.type = type
        self.giftBox = _IndirectBox(gift)
        self.ownedGiftId = ownedGiftId
        self.senderUserBox = senderUser.map(_IndirectBox.init)
        self.sendDate = sendDate
        self.isSaved = isSaved
        self.canBeTransferred = canBeTransferred
        self.transferStarCount = transferStarCount
        self.nextTransferDate = nextTransferDate
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case giftBox = "gift"
        case ownedGiftId = "owned_gift_id"
        case senderUserBox = "sender_user"
        case sendDate = "send_date"
        case isSaved = "is_saved"
        case canBeTransferred = "can_be_transferred"
        case transferStarCount = "transfer_star_count"
        case nextTransferDate = "next_transfer_date"
    }
}
