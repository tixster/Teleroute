// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the model of a unique gift.
public struct UniqueGiftModel: Codable, Hashable, Sendable {
    /// Name of the model
    public var name: Swift.String

    private var stickerBox: _IndirectBox<Sticker>
    /// The sticker that represents the unique gift
    public var sticker: Sticker {
        get { self.stickerBox.value }
        set { self.stickerBox = _IndirectBox(newValue) }
    }

    /// The number of unique gifts that receive this model for every 1000 gift upgrades. Always
    /// 0 for crafted gifts.
    public var rarityPerMille: Swift.Int64

    /// *Optional*. Rarity of the model if it is a crafted model. Currently, can be “uncommon”,
    /// “rare”, “epic”, or “legendary”.
    public var rarity: UniqueGiftModelRarity?

    public init(
        name: Swift.String,
        sticker: Sticker,
        rarityPerMille: Swift.Int64,
        rarity: UniqueGiftModelRarity? = nil
    ) {
        self.name = name
        self.stickerBox = _IndirectBox(sticker)
        self.rarityPerMille = rarityPerMille
        self.rarity = rarity
    }

    public enum CodingKeys: String, CodingKey {
        case name
        case stickerBox = "sticker"
        case rarityPerMille = "rarity_per_mille"
        case rarity
    }
}
