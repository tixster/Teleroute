// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a sticker.
public struct Sticker: Codable, Hashable, Sendable {
    /// Identifier for this file, which can be used to download or reuse the file
    public var fileId: Swift.String

    /// Unique identifier for this file, which is supposed to be the same over time and for
    /// different bots. Can't be used to download or reuse the file.
    public var fileUniqueId: Swift.String

    /// Type of the sticker, currently one of “regular”, “mask”, “custom_emoji”. The type of the
    /// sticker is independent from its format, which is determined by the fields *is_animated*
    /// and *is_video*.
    public var type: StickerType

    /// Sticker width
    public var width: Swift.Int64

    /// Sticker height
    public var height: Swift.Int64

    /// *True*, if the sticker is [animated](https://telegram.org/blog/animated-stickers)
    public var isAnimated: Swift.Bool

    /// *True*, if the sticker is a [video
    /// sticker](https://telegram.org/blog/video-stickers-better-reactions)
    public var isVideo: Swift.Bool

    /// *Optional*. Sticker thumbnail in the .WEBP or .JPG format
    public var thumbnail: PhotoSize?

    /// *Optional*. Emoji associated with the sticker
    public var emoji: Swift.String?

    /// *Optional*. Name of the sticker set to which the sticker belongs
    public var setName: Swift.String?

    /// *Optional*. For premium regular stickers, premium animation for the sticker
    public var premiumAnimation: File?

    /// *Optional*. For mask stickers, the position where the mask should be placed
    public var maskPosition: MaskPosition?

    /// *Optional*. For custom emoji stickers, unique identifier of the custom emoji
    public var customEmojiId: Swift.String?

    /// *Optional*. *True*, if the sticker must be repainted to a text color in messages, the
    /// color of the Telegram Premium badge in emoji status, white color on chat photos, or
    /// another appropriate color in other places
    public var needsRepainting: Swift.Bool?

    /// *Optional*. File size in bytes
    public var fileSize: Swift.Int64?

    public init(
        fileId: Swift.String,
        fileUniqueId: Swift.String,
        type: StickerType,
        width: Swift.Int64,
        height: Swift.Int64,
        isAnimated: Swift.Bool,
        isVideo: Swift.Bool,
        thumbnail: PhotoSize? = nil,
        emoji: Swift.String? = nil,
        setName: Swift.String? = nil,
        premiumAnimation: File? = nil,
        maskPosition: MaskPosition? = nil,
        customEmojiId: Swift.String? = nil,
        needsRepainting: Swift.Bool? = nil,
        fileSize: Swift.Int64? = nil
    ) {
        self.fileId = fileId
        self.fileUniqueId = fileUniqueId
        self.type = type
        self.width = width
        self.height = height
        self.isAnimated = isAnimated
        self.isVideo = isVideo
        self.thumbnail = thumbnail
        self.emoji = emoji
        self.setName = setName
        self.premiumAnimation = premiumAnimation
        self.maskPosition = maskPosition
        self.customEmojiId = customEmojiId
        self.needsRepainting = needsRepainting
        self.fileSize = fileSize
    }

    public enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case type
        case width
        case height
        case isAnimated = "is_animated"
        case isVideo = "is_video"
        case thumbnail
        case emoji
        case setName = "set_name"
        case premiumAnimation = "premium_animation"
        case maskPosition = "mask_position"
        case customEmojiId = "custom_emoji_id"
        case needsRepainting = "needs_repainting"
        case fileSize = "file_size"
    }
}
