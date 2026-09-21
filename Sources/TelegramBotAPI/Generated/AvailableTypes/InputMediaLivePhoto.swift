// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a live photo to be sent.
public struct InputMediaLivePhoto: Codable, Hashable, Sendable {
    /// Type of the media, must be *live_photo*
    public var type: InputPollMediaKind

    /// Video of the live photo to send. Pass a file_id to send a file that exists on the
    /// Telegram servers (recommended) or pass “attach://<file_attach_name>” to upload a new one
    /// using multipart/form-data under <file_attach_name> name. More information on Sending
    /// Files ». Sending live photos by a URL is currently unsupported.
    public var media: Swift.String

    /// The static photo to send. Pass a file_id to send a file that exists on the Telegram
    /// servers (recommended) or pass “attach://<file_attach_name>” to upload a new one using
    /// multipart/form-data under <file_attach_name> name. More information on Sending Files ».
    /// Sending live photos by a URL is currently unsupported.
    public var photo: Swift.String

    /// *Optional*. Caption of the live photo to be sent, 0-1024 characters after entities
    /// parsing
    public var caption: Swift.String?

    /// *Optional*. Mode for parsing entities in the live photo caption. See formatting options
    /// for more details.
    public var parseMode: Swift.String?

    /// *Optional*. List of special entities that appear in the caption, which can be specified
    /// instead of *parse_mode*
    public var captionEntities: [MessageEntity]?

    /// *Optional*. Pass *True* if the caption must be shown above the message media
    public var showCaptionAboveMedia: Swift.Bool?

    /// *Optional*. Pass *True* if the live photo needs to be covered with a spoiler animation
    public var hasSpoiler: Swift.Bool?

    public init(
        type: InputPollMediaKind = .livePhoto,
        media: Swift.String,
        photo: Swift.String,
        caption: Swift.String? = nil,
        parseMode: Swift.String? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Swift.Bool? = nil,
        hasSpoiler: Swift.Bool? = nil
    ) {
        self.type = type
        self.media = media
        self.photo = photo
        self.caption = caption
        self.parseMode = parseMode
        self.captionEntities = captionEntities
        self.showCaptionAboveMedia = showCaptionAboveMedia
        self.hasSpoiler = hasSpoiler
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case media
        case photo
        case caption
        case parseMode = "parse_mode"
        case captionEntities = "caption_entities"
        case showCaptionAboveMedia = "show_caption_above_media"
        case hasSpoiler = "has_spoiler"
    }
}
