// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the symbol shown on the pattern of a unique gift.
public struct UniqueGiftSymbol: Codable, Hashable, Sendable {
    /// Name of the symbol
    public var name: Swift.String

    private var stickerBox: _IndirectBox<Sticker>
    /// The sticker that represents the unique gift
    public var sticker: Sticker {
        get { self.stickerBox.value }
        set { self.stickerBox = _IndirectBox(newValue) }
    }

    /// The number of unique gifts that receive this model for every 1000 gifts upgraded
    public var rarityPerMille: Swift.Int64

    public init(
        name: Swift.String,
        sticker: Sticker,
        rarityPerMille: Swift.Int64
    ) {
        self.name = name
        self.stickerBox = _IndirectBox(sticker)
        self.rarityPerMille = rarityPerMille
    }

    public enum CodingKeys: String, CodingKey {
        case name
        case stickerBox = "sticker"
        case rarityPerMille = "rarity_per_mille"
    }
}
