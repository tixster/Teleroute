// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a link to an animated GIF file. By default, this animated GIF file will be sent
/// by the user with optional caption. Alternatively, you can use *input_message_content* to
/// send a message with the specified content instead of the animation.
public struct InlineQueryResultGif: Codable, Hashable, Sendable {
    /// Type of the result, must be *gif*
    public var type: InlineQueryResultKind

    /// Unique identifier for this result, 1-64 bytes
    public var id: Swift.String

    /// A valid URL for the GIF file
    public var gifUrl: Swift.String

    /// *Optional*. Width of the GIF
    public var gifWidth: Swift.Int64?

    /// *Optional*. Height of the GIF
    public var gifHeight: Swift.Int64?

    /// *Optional*. Duration of the GIF in seconds
    public var gifDuration: Swift.Int64?

    /// URL of the static (JPEG or GIF) or animated (MPEG4) thumbnail for the result
    public var thumbnailUrl: Swift.String

    /// *Optional*. MIME type of the thumbnail, must be one of “image/jpeg”, “image/gif”, or
    /// “video/mp4”. Defaults to “image/jpeg”.
    public var thumbnailMimeType: Swift.String?

    /// *Optional*. Title for the result
    public var title: Swift.String?

    /// *Optional*. Caption of the GIF file to be sent, 0-1024 characters after entities parsing
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
    /// *Optional*. Content of the message to be sent instead of the GIF animation
    public var inputMessageContent: InputMessageContent? {
        get { self.inputMessageContentBox?.value }
        set { self.inputMessageContentBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        type: InlineQueryResultKind = .gif,
        id: Swift.String,
        gifUrl: Swift.String,
        gifWidth: Swift.Int64? = nil,
        gifHeight: Swift.Int64? = nil,
        gifDuration: Swift.Int64? = nil,
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
        self.gifUrl = gifUrl
        self.gifWidth = gifWidth
        self.gifHeight = gifHeight
        self.gifDuration = gifDuration
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
        case gifUrl = "gif_url"
        case gifWidth = "gif_width"
        case gifHeight = "gif_height"
        case gifDuration = "gif_duration"
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
