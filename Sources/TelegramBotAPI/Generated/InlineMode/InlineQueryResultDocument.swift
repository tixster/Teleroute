// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a link to a file. By default, this file will be sent by the user with an optional
/// caption. Alternatively, you can use *input_message_content* to send a message with the
/// specified content instead of the file. Currently, only **.PDF** and **.ZIP** files can be
/// sent using this method.
public struct InlineQueryResultDocument: Codable, Hashable, Sendable {
    /// Type of the result, must be *document*
    public var type: InlineQueryResultKind

    /// Unique identifier for this result, 1-64 bytes
    public var id: Swift.String

    /// Title for the result
    public var title: Swift.String

    /// *Optional*. Caption of the document to be sent, 0-1024 characters after entities parsing
    public var caption: Swift.String?

    /// *Optional*. Mode for parsing entities in the document caption. See formatting options
    /// for more details.
    public var parseMode: Swift.String?

    /// *Optional*. List of special entities that appear in the caption, which can be specified
    /// instead of *parse_mode*
    public var captionEntities: [MessageEntity]?

    /// A valid URL for the file
    public var documentUrl: Swift.String

    /// MIME type of the content of the file, either “application/pdf” or “application/zip”
    public var mimeType: Swift.String

    /// *Optional*. Short description of the result
    public var description: Swift.String?

    /// *Optional*. Inline keyboard attached to the message
    public var replyMarkup: InlineKeyboardMarkup?

    private var inputMessageContentBox: _IndirectBox<InputMessageContent>?
    /// *Optional*. Content of the message to be sent instead of the file
    public var inputMessageContent: InputMessageContent? {
        get { self.inputMessageContentBox?.value }
        set { self.inputMessageContentBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. URL of the thumbnail (JPEG only) for the file
    public var thumbnailUrl: Swift.String?

    /// *Optional*. Thumbnail width
    public var thumbnailWidth: Swift.Int64?

    /// *Optional*. Thumbnail height
    public var thumbnailHeight: Swift.Int64?

    public init(
        type: InlineQueryResultKind = .document,
        id: Swift.String,
        title: Swift.String,
        caption: Swift.String? = nil,
        parseMode: Swift.String? = nil,
        captionEntities: [MessageEntity]? = nil,
        documentUrl: Swift.String,
        mimeType: Swift.String,
        description: Swift.String? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil,
        inputMessageContent: InputMessageContent? = nil,
        thumbnailUrl: Swift.String? = nil,
        thumbnailWidth: Swift.Int64? = nil,
        thumbnailHeight: Swift.Int64? = nil
    ) {
        self.type = type
        self.id = id
        self.title = title
        self.caption = caption
        self.parseMode = parseMode
        self.captionEntities = captionEntities
        self.documentUrl = documentUrl
        self.mimeType = mimeType
        self.description = description
        self.replyMarkup = replyMarkup
        self.inputMessageContentBox = inputMessageContent.map(_IndirectBox.init)
        self.thumbnailUrl = thumbnailUrl
        self.thumbnailWidth = thumbnailWidth
        self.thumbnailHeight = thumbnailHeight
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case id
        case title
        case caption
        case parseMode = "parse_mode"
        case captionEntities = "caption_entities"
        case documentUrl = "document_url"
        case mimeType = "mime_type"
        case description
        case replyMarkup = "reply_markup"
        case inputMessageContentBox = "input_message_content"
        case thumbnailUrl = "thumbnail_url"
        case thumbnailWidth = "thumbnail_width"
        case thumbnailHeight = "thumbnail_height"
    }
}
