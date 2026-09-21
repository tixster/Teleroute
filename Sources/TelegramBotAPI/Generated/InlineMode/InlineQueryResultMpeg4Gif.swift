// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a link to a video animation (H.264/MPEG-4 AVC video without sound). By default,
/// this animated MPEG-4 file will be sent by the user with optional caption. Alternatively, you
/// can use *input_message_content* to send a message with the specified content instead of the
/// animation.
public struct InlineQueryResultMpeg4Gif: Codable, Hashable, Sendable {
    /// Type of the result, must be *mpeg4_gif*
    public var type: InlineQueryResultKind

    /// Unique identifier for this result, 1-64 bytes
    public var id: Swift.String

    /// A valid URL for the MPEG4 file
    public var mpeg4Url: Swift.String

    /// *Optional*. Video width
    public var mpeg4Width: Swift.Int64?

    /// *Optional*. Video height
    public var mpeg4Height: Swift.Int64?

    /// *Optional*. Video duration in seconds
    public var mpeg4Duration: Swift.Int64?

    /// URL of the static (JPEG or GIF) or animated (MPEG4) thumbnail for the result
    public var thumbnailUrl: Swift.String

    /// *Optional*. MIME type of the thumbnail, must be one of “image/jpeg”, “image/gif”, or
    /// “video/mp4”. Defaults to “image/jpeg”.
    public var thumbnailMimeType: Swift.String?

    /// *Optional*. Title for the result
    public var title: Swift.String?

    /// *Optional*. Caption of the MPEG-4 file to be sent, 0-1024 characters after entities
    /// parsing
    public var caption: Swift.String?

    /// *Optional*. Mode for parsing entities in the caption. See formatting options for more
    /// details.
    public var parseMode: Swift.String?

    /// *Optional*. List of special entities that appear in the caption, which can be specified
    /// instead of *parse_mode*
    public var captionEntities: [MessageEntity]?

    /// *Optional*. Pass *True* if the caption must be shown above the message media
    public var showCaptionAboveMedia: Swift.Bool?

    /// *Optional*. Inline keyboard attached to the message
    public var replyMarkup: InlineKeyboardMarkup?

    private var inputMessageContentBox: _IndirectBox<InputMessageContent>?
    /// *Optional*. Content of the message to be sent instead of the video animation
    public var inputMessageContent: InputMessageContent? {
        get { self.inputMessageContentBox?.value }
        set { self.inputMessageContentBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        type: InlineQueryResultKind = .mpeg4Gif,
        id: Swift.String,
        mpeg4Url: Swift.String,
        mpeg4Width: Swift.Int64? = nil,
        mpeg4Height: Swift.Int64? = nil,
        mpeg4Duration: Swift.Int64? = nil,
        thumbnailUrl: Swift.String,
        thumbnailMimeType: Swift.String? = nil,
        title: Swift.String? = nil,
        caption: Swift.String? = nil,
        parseMode: Swift.String? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Swift.Bool? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil,
        inputMessageContent: InputMessageContent? = nil
    ) {
        self.type = type
        self.id = id
        self.mpeg4Url = mpeg4Url
        self.mpeg4Width = mpeg4Width
        self.mpeg4Height = mpeg4Height
        self.mpeg4Duration = mpeg4Duration
        self.thumbnailUrl = thumbnailUrl
        self.thumbnailMimeType = thumbnailMimeType
        self.title = title
        self.caption = caption
        self.parseMode = parseMode
        self.captionEntities = captionEntities
        self.showCaptionAboveMedia = showCaptionAboveMedia
        self.replyMarkup = replyMarkup
        self.inputMessageContentBox = inputMessageContent.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case id
        case mpeg4Url = "mpeg4_url"
        case mpeg4Width = "mpeg4_width"
        case mpeg4Height = "mpeg4_height"
        case mpeg4Duration = "mpeg4_duration"
        case thumbnailUrl = "thumbnail_url"
        case thumbnailMimeType = "thumbnail_mime_type"
        case title
        case caption
        case parseMode = "parse_mode"
        case captionEntities = "caption_entities"
        case showCaptionAboveMedia = "show_caption_above_media"
        case replyMarkup = "reply_markup"
        case inputMessageContentBox = "input_message_content"
    }
}
