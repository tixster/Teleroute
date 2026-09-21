// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a link to an article or web page.
public struct InlineQueryResultArticle: Codable, Hashable, Sendable {
    /// Type of the result, must be *article*
    public var type: InlineQueryResultKind

    /// Unique identifier for this result, 1-64 Bytes
    public var id: Swift.String

    /// Title of the result
    public var title: Swift.String

    private var inputMessageContentBox: _IndirectBox<InputMessageContent>
    /// Content of the message to be sent
    public var inputMessageContent: InputMessageContent {
        get { self.inputMessageContentBox.value }
        set { self.inputMessageContentBox = _IndirectBox(newValue) }
    }

    /// *Optional*. Inline keyboard attached to the message
    public var replyMarkup: InlineKeyboardMarkup?

    /// *Optional*. URL of the result
    public var url: Swift.String?

    /// *Optional*. Short description of the result
    public var description: Swift.String?

    /// *Optional*. Url of the thumbnail for the result
    public var thumbnailUrl: Swift.String?

    /// *Optional*. Thumbnail width
    public var thumbnailWidth: Swift.Int64?

    /// *Optional*. Thumbnail height
    public var thumbnailHeight: Swift.Int64?

    public init(
        type: InlineQueryResultKind = .article,
        id: Swift.String,
        title: Swift.String,
        inputMessageContent: InputMessageContent,
        replyMarkup: InlineKeyboardMarkup? = nil,
        url: Swift.String? = nil,
        description: Swift.String? = nil,
        thumbnailUrl: Swift.String? = nil,
        thumbnailWidth: Swift.Int64? = nil,
        thumbnailHeight: Swift.Int64? = nil
    ) {
        self.type = type
        self.id = id
        self.title = title
        self.inputMessageContentBox = _IndirectBox(inputMessageContent)
        self.replyMarkup = replyMarkup
        self.url = url
        self.description = description
        self.thumbnailUrl = thumbnailUrl
        self.thumbnailWidth = thumbnailWidth
        self.thumbnailHeight = thumbnailHeight
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case id
        case title
        case inputMessageContentBox = "input_message_content"
        case replyMarkup = "reply_markup"
        case url
        case description
        case thumbnailUrl = "thumbnail_url"
        case thumbnailWidth = "thumbnail_width"
        case thumbnailHeight = "thumbnail_height"
    }
}
