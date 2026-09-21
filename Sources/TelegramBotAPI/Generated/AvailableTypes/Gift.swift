// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a gift that can be sent by the bot.
public struct Gift: Codable, Hashable, Sendable {
    /// Unique identifier of the gift
    public var id: Swift.String

    private var stickerBox: _IndirectBox<Sticker>
    /// The sticker that represents the gift
    public var sticker: Sticker {
        get { self.stickerBox.value }
        set { self.stickerBox = _IndirectBox(newValue) }
    }

    /// The number of Telegram Stars that must be paid to send the sticker
    public var starCount: Swift.Int64

    /// *Optional*. The number of Telegram Stars that must be paid to upgrade the gift to a
    /// unique one
    public var upgradeStarCount: Swift.Int64?

    /// *Optional*. *True*, if the gift can only be purchased by Telegram Premium subscribers
    public var isPremium: Swift.Bool?

    /// *Optional*. *True*, if the gift can be used (after being upgraded) to customize a user's
    /// appearance
    public var hasColors: Swift.Bool?

    /// *Optional*. The total number of gifts of this type that can be sent by all users; for
    /// limited gifts only
    public var totalCount: Swift.Int64?

    /// *Optional*. The number of remaining gifts of this type that can be sent by all users;
    /// for limited gifts only
    public var remainingCount: Swift.Int64?

    /// *Optional*. The total number of gifts of this type that can be sent by the bot; for
    /// limited gifts only
    public var personalTotalCount: Swift.Int64?

    /// *Optional*. The number of remaining gifts of this type that can be sent by the bot; for
    /// limited gifts only
    public var personalRemainingCount: Swift.Int64?

    /// *Optional*. Background of the gift
    public var background: GiftBackground?

    /// *Optional*. The total number of different unique gifts that can be obtained by upgrading
    /// the gift
    public var uniqueGiftVariantCount: Swift.Int64?

    private var publisherChatBox: _IndirectBox<Chat>?
    /// *Optional*. Information about the chat that published the gift
    public var publisherChat: Chat? {
        get { self.publisherChatBox?.value }
        set { self.publisherChatBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        id: Swift.String,
        sticker: Sticker,
        starCount: Swift.Int64,
        upgradeStarCount: Swift.Int64? = nil,
        isPremium: Swift.Bool? = nil,
        hasColors: Swift.Bool? = nil,
        totalCount: Swift.Int64? = nil,
        remainingCount: Swift.Int64? = nil,
        personalTotalCount: Swift.Int64? = nil,
        personalRemainingCount: Swift.Int64? = nil,
        background: GiftBackground? = nil,
        uniqueGiftVariantCount: Swift.Int64? = nil,
        publisherChat: Chat? = nil
    ) {
        self.id = id
        self.stickerBox = _IndirectBox(sticker)
        self.starCount = starCount
        self.upgradeStarCount = upgradeStarCount
        self.isPremium = isPremium
        self.hasColors = hasColors
        self.totalCount = totalCount
        self.remainingCount = remainingCount
        self.personalTotalCount = personalTotalCount
        self.personalRemainingCount = personalRemainingCount
        self.background = background
        self.uniqueGiftVariantCount = uniqueGiftVariantCount
        self.publisherChatBox = publisherChat.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case stickerBox = "sticker"
        case starCount = "star_count"
        case upgradeStarCount = "upgrade_star_count"
        case isPremium = "is_premium"
        case hasColors = "has_colors"
        case totalCount = "total_count"
        case remainingCount = "remaining_count"
        case personalTotalCount = "personal_total_count"
        case personalRemainingCount = "personal_remaining_count"
        case background
        case uniqueGiftVariantCount = "unique_gift_variant_count"
        case publisherChatBox = "publisher_chat"
    }
}
