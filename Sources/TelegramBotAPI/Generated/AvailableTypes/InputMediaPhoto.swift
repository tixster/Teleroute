// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a photo to be sent.
public struct InputMediaPhoto: Codable, Hashable, Sendable {
    /// Type of the media, must be *photo*
    public var type: InputPollMediaKind

    /// File to send. Pass a file_id to send a file that exists on the Telegram servers
    /// (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass
    /// “attach://<file_attach_name>” to upload a new one using multipart/form-data under
    /// <file_attach_name> name. More information on Sending Files »
    public var media: Swift.String

    /// *Optional*. Caption of the photo to be sent, 0-1024 characters after entities parsing
    public var caption: Swift.String?

    /// *Optional*. Mode for parsing entities in the photo caption. See formatting options for
    /// more details.
    public var parseMode: Swift.String?

    /// *Optional*. List of special entities that appear in the caption, which can be specified
    /// instead of *parse_mode*
    public var captionEntities: [MessageEntity]?

    /// *Optional*. Pass *True* if the caption must be shown above the message media
    public var showCaptionAboveMedia: Swift.Bool?

    /// *Optional*. Pass *True* if the photo needs to be covered with a spoiler animation
    public var hasSpoiler: Swift.Bool?

    public init(
        type: InputPollMediaKind = .photo,
        media: Swift.String,
        caption: Swift.String? = nil,
        parseMode: Swift.String? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Swift.Bool? = nil,
        hasSpoiler: Swift.Bool? = nil
    ) {
        self.type = type
        self.media = media
        self.caption = caption
        self.parseMode = parseMode
        self.captionEntities = captionEntities
        self.showCaptionAboveMedia = showCaptionAboveMedia
        self.hasSpoiler = hasSpoiler
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case media
        case caption
        case parseMode = "parse_mode"
        case captionEntities = "caption_entities"
        case showCaptionAboveMedia = "show_caption_above_media"
        case hasSpoiler = "has_spoiler"
    }
}
