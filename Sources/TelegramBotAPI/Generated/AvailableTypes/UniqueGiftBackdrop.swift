// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the backdrop of a unique gift.
public struct UniqueGiftBackdrop: Codable, Hashable, Sendable {
    /// Name of the backdrop
    public var name: Swift.String

    /// Colors of the backdrop
    public var colors: UniqueGiftBackdropColors

    /// The number of unique gifts that receive this backdrop for every 1000 gifts upgraded
    public var rarityPerMille: Swift.Int64

    public init(
        name: Swift.String,
        colors: UniqueGiftBackdropColors,
        rarityPerMille: Swift.Int64
    ) {
        self.name = name
        self.colors = colors
        self.rarityPerMille = rarityPerMille
    }

    public enum CodingKeys: String, CodingKey {
        case name
        case colors
        case rarityPerMille = "rarity_per_mille"
    }
}
