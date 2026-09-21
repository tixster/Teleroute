// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes a sticker to be added to a sticker set.
public struct InputSticker: Codable, Hashable, Sendable {
    /// The added sticker. Pass a *file_id* as a String to send a file that already exists on
    /// the Telegram servers, pass an HTTP URL as a String for Telegram to get a file from the
    /// Internet, or pass “attach://<file_attach_name>” to upload a new file using
    /// multipart/form-data under <file_attach_name> name. Animated and video stickers can't be
    /// uploaded via HTTP URL. More information on Sending Files »
    public var sticker: Swift.String

    /// Format of the added sticker, must be one of “static” for a **.WEBP** or **.PNG** image,
    /// “animated” for a **.TGS** animation, “video” for a **.WEBM** video
    public var format: InputStickerFormat

    /// List of 1-20 emoji associated with the sticker
    public var emojiList: [Swift.String]

    /// *Optional*. Position where the mask should be placed on faces. For “mask” stickers only.
    public var maskPosition: MaskPosition?

    /// *Optional*. List of 0-20 search keywords for the sticker with total length of up to 64
    /// characters. For “regular” and “custom_emoji” stickers only.
    public var keywords: [Swift.String]?

    public init(
        sticker: Swift.String,
        format: InputStickerFormat,
        emojiList: [Swift.String],
        maskPosition: MaskPosition? = nil,
        keywords: [Swift.String]? = nil
    ) {
        self.sticker = sticker
        self.format = format
        self.emojiList = emojiList
        self.maskPosition = maskPosition
        self.keywords = keywords
    }

    public enum CodingKeys: String, CodingKey {
        case sticker
        case format
        case emojiList = "emoji_list"
        case maskPosition = "mask_position"
        case keywords
    }
}
