// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a link to a photo stored on the Telegram servers. By default, this photo will be
/// sent by the user with an optional caption. Alternatively, you can use
/// *input_message_content* to send a message with the specified content instead of the photo.
public struct InlineQueryResultCachedPhoto: Codable, Hashable, Sendable {
    /// Type of the result, must be *photo*
    public var type: InlineQueryResultKind

    /// Unique identifier for this result, 1-64 bytes
    public var id: Swift.String

    /// A valid file identifier of the photo
    public var photoFileId: Swift.String

    /// *Optional*. Title for the result
    public var title: Swift.String?

    /// *Optional*. Short description of the result
    public var description: Swift.String?

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

    /// *Optional*. Inline keyboard attached to the message
    public var replyMarkup: InlineKeyboardMarkup?

    private var inputMessageContentBox: _IndirectBox<InputMessageContent>?
    /// *Optional*. Content of the message to be sent instead of the photo
    public var inputMessageContent: InputMessageContent? {
        get { self.inputMessageContentBox?.value }
        set { self.inputMessageContentBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        type: InlineQueryResultKind = .photo,
        id: Swift.String,
        photoFileId: Swift.String,
        title: Swift.String? = nil,
        description: Swift.String? = nil,
        caption: Swift.String? = nil,
        parseMode: Swift.String? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Swift.Bool? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil,
        inputMessageContent: InputMessageContent? = nil
    ) {
        self.type = type
        self.id = id
        self.photoFileId = photoFileId
        self.title = title
        self.description = description
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
        case photoFileId = "photo_file_id"
        case title
        case description
        case caption
        case parseMode = "parse_mode"
        case captionEntities = "caption_entities"
        case showCaptionAboveMedia = "show_caption_above_media"
        case replyMarkup = "reply_markup"
        case inputMessageContentBox = "input_message_content"
    }
}
