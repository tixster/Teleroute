// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a sticker set.
public struct StickerSet: Codable, Hashable, Sendable {
    /// Sticker set name
    public var name: Swift.String

    /// Sticker set title
    public var title: Swift.String

    /// Type of stickers in the set, currently one of “regular”, “mask”, “custom_emoji”
    public var stickerType: StickerType

    /// List of all set stickers
    public var stickers: [Sticker]

    /// *Optional*. Sticker set thumbnail in the .WEBP, .TGS, or .WEBM format
    public var thumbnail: PhotoSize?

    public init(
        name: Swift.String,
        title: Swift.String,
        stickerType: StickerType,
        stickers: [Sticker],
        thumbnail: PhotoSize? = nil
    ) {
        self.name = name
        self.title = title
        self.stickerType = stickerType
        self.stickers = stickers
        self.thumbnail = thumbnail
    }

    public enum CodingKeys: String, CodingKey {
        case name
        case title
        case stickerType = "sticker_type"
        case stickers
        case thumbnail
    }
}
