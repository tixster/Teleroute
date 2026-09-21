// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a link to a page containing an embedded video player or a video file. By default,
/// this video file will be sent by the user with an optional caption. Alternatively, you can
/// use *input_message_content* to send a message with the specified content instead of the
/// video. If an InlineQueryResultVideo message contains an embedded video (e.g., YouTube), you
/// **must** replace its content using *input_message_content*.
public struct InlineQueryResultVideo: Codable, Hashable, Sendable {
    /// Type of the result, must be *video*
    public var type: InlineQueryResultKind

    /// Unique identifier for this result, 1-64 bytes
    public var id: Swift.String

    /// A valid URL for the embedded video player or video file
    public var videoUrl: Swift.String

    /// MIME type of the content of the video URL, “text/html” or “video/mp4”
    public var mimeType: Swift.String

    /// URL of the thumbnail (JPEG only) for the video
    public var thumbnailUrl: Swift.String

    /// Title for the result
    public var title: Swift.String

    /// *Optional*. Caption of the video to be sent, 0-1024 characters after entities parsing
    public var caption: Swift.String?

    /// *Optional*. Mode for parsing entities in the video caption. See formatting options for
    /// more details.
    public var parseMode: Swift.String?

    /// *Optional*. List of special entities that appear in the caption, which can be specified
    /// instead of *parse_mode*
    public var captionEntities: [MessageEntity]?

    /// *Optional*. Pass *True* if the caption must be shown above the message media
    public var showCaptionAboveMedia: Swift.Bool?

    /// *Optional*. Video width
    public var videoWidth: Swift.Int64?

    /// *Optional*. Video height
    public var videoHeight: Swift.Int64?

    /// *Optional*. Video duration in seconds
    public var videoDuration: Swift.Int64?

    /// *Optional*. Short description of the result
    public var description: Swift.String?

    /// *Optional*. Inline keyboard attached to the message
    public var replyMarkup: InlineKeyboardMarkup?

    private var inputMessageContentBox: _IndirectBox<InputMessageContent>?
    /// *Optional*. Content of the message to be sent instead of the video. This field is
    /// **required** if InlineQueryResultVideo is used to send an HTML-page as a result (e.g., a
    /// YouTube video).
    public var inputMessageContent: InputMessageContent? {
        get { self.inputMessageContentBox?.value }
        set { self.inputMessageContentBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        type: InlineQueryResultKind = .video,
        id: Swift.String,
        videoUrl: Swift.String,
        mimeType: Swift.String,
        thumbnailUrl: Swift.String,
        title: Swift.String,
        caption: Swift.String? = nil,
        parseMode: Swift.String? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Swift.Bool? = nil,
        videoWidth: Swift.Int64? = nil,
        videoHeight: Swift.Int64? = nil,
        videoDuration: Swift.Int64? = nil,
        description: Swift.String? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil,
        inputMessageContent: InputMessageContent? = nil
    ) {
        self.type = type
        self.id = id
        self.videoUrl = videoUrl
        self.mimeType = mimeType
        self.thumbnailUrl = thumbnailUrl
        self.title = title
        self.caption = caption
        self.parseMode = parseMode
        self.captionEntities = captionEntities
        self.showCaptionAboveMedia = showCaptionAboveMedia
        self.videoWidth = videoWidth
        self.videoHeight = videoHeight
        self.videoDuration = videoDuration
        self.description = description
        self.replyMarkup = replyMarkup
        self.inputMessageContentBox = inputMessageContent.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case id
        case videoUrl = "video_url"
        case mimeType = "mime_type"
        case thumbnailUrl = "thumbnail_url"
        case title
        case caption
        case parseMode = "parse_mode"
        case captionEntities = "caption_entities"
        case showCaptionAboveMedia = "show_caption_above_media"
        case videoWidth = "video_width"
        case videoHeight = "video_height"
        case videoDuration = "video_duration"
        case description
        case replyMarkup = "reply_markup"
        case inputMessageContentBox = "input_message_content"
    }
}
