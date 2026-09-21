// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a sticker file to be sent.
public struct InputMediaSticker: Codable, Hashable, Sendable {
    /// Type of the media, must be *sticker*
    public var type: InputPollOptionMediaKind

    /// File to send. Pass a file_id to send a file that exists on the Telegram servers
    /// (recommended), pass an HTTP URL for Telegram to get a .WEBP sticker from the Internet,
    /// or pass “attach://<file_attach_name>” to upload a new .WEBP, .TGS, or .WEBM sticker
    /// using multipart/form-data under <file_attach_name> name. More information on Sending
    /// Files »
    public var media: Swift.String

    /// *Optional*. Emoji associated with the sticker; only for just uploaded stickers
    public var emoji: Swift.String?

    public init(
        type: InputPollOptionMediaKind = .sticker,
        media: Swift.String,
        emoji: Swift.String? = nil
    ) {
        self.type = type
        self.media = media
        self.emoji = emoji
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case media
        case emoji
    }
}
