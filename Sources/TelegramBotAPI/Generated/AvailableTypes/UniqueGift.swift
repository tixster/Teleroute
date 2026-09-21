// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes a unique gift that was upgraded from a regular gift.
public struct UniqueGift: Codable, Hashable, Sendable {
    /// Identifier of the regular gift from which the gift was upgraded
    public var giftId: Swift.String

    /// Human-readable name of the regular gift from which this unique gift was upgraded
    public var baseName: Swift.String

    /// Unique name of the gift. This name can be used in `https://t.me/nft/...` links and story
    /// areas.
    public var name: Swift.String

    /// Unique number of the upgraded gift among gifts upgraded from the same regular gift
    public var number: Swift.Int64

    private var modelBox: _IndirectBox<UniqueGiftModel>
    /// Model of the gift
    public var model: UniqueGiftModel {
        get { self.modelBox.value }
        set { self.modelBox = _IndirectBox(newValue) }
    }

    private var symbolBox: _IndirectBox<UniqueGiftSymbol>
    /// Symbol of the gift
    public var symbol: UniqueGiftSymbol {
        get { self.symbolBox.value }
        set { self.symbolBox = _IndirectBox(newValue) }
    }

    /// Backdrop of the gift
    public var backdrop: UniqueGiftBackdrop

    /// *Optional*. *True*, if the original regular gift was exclusively purchaseable by
    /// Telegram Premium subscribers
    public var isPremium: Swift.Bool?

    /// *Optional*. *True*, if the gift was used to craft another gift and isn't available
    /// anymore
    public var isBurned: Swift.Bool?

    /// *Optional*. *True*, if the gift is assigned from the TON blockchain and can't be resold
    /// or transferred in Telegram
    public var isFromBlockchain: Swift.Bool?

    /// *Optional*. The color scheme that can be used by the gift's owner for the chat's name,
    /// replies to messages and link previews; for business account gifts and gifts that are
    /// currently on sale only
    public var colors: UniqueGiftColors?

    private var publisherChatBox: _IndirectBox<Chat>?
    /// *Optional*. Information about the chat that published the gift
    public var publisherChat: Chat? {
        get { self.publisherChatBox?.value }
        set { self.publisherChatBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        giftId: Swift.String,
        baseName: Swift.String,
        name: Swift.String,
        number: Swift.Int64,
        model: UniqueGiftModel,
        symbol: UniqueGiftSymbol,
        backdrop: UniqueGiftBackdrop,
        isPremium: Swift.Bool? = nil,
        isBurned: Swift.Bool? = nil,
        isFromBlockchain: Swift.Bool? = nil,
        colors: UniqueGiftColors? = nil,
        publisherChat: Chat? = nil
    ) {
        self.giftId = giftId
        self.baseName = baseName
        self.name = name
        self.number = number
        self.modelBox = _IndirectBox(model)
        self.symbolBox = _IndirectBox(symbol)
        self.backdrop = backdrop
        self.isPremium = isPremium
        self.isBurned = isBurned
        self.isFromBlockchain = isFromBlockchain
        self.colors = colors
        self.publisherChatBox = publisherChat.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case giftId = "gift_id"
        case baseName = "base_name"
        case name
        case number
        case modelBox = "model"
        case symbolBox = "symbol"
        case backdrop
        case isPremium = "is_premium"
        case isBurned = "is_burned"
        case isFromBlockchain = "is_from_blockchain"
        case colors
        case publisherChatBox = "publisher_chat"
    }
}
