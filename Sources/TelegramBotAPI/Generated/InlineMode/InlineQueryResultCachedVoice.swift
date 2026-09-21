// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a link to a voice message stored on the Telegram servers. By default, this voice
/// message will be sent by the user. Alternatively, you can use *input_message_content* to send
/// a message with the specified content instead of the voice message.
public struct InlineQueryResultCachedVoice: Codable, Hashable, Sendable {
    /// Type of the result, must be *voice*
    public var type: InlineQueryResultKind

    /// Unique identifier for this result, 1-64 bytes
    public var id: Swift.String

    /// A valid file identifier for the voice message
    public var voiceFileId: Swift.String

    /// Voice message title
    public var title: Swift.String

    /// *Optional*. Caption, 0-1024 characters after entities parsing
    public var caption: Swift.String?

    /// *Optional*. Mode for parsing entities in the voice message caption. See formatting
    /// options for more details.
    public var parseMode: Swift.String?

    /// *Optional*. List of special entities that appear in the caption, which can be specified
    /// instead of *parse_mode*
    public var captionEntities: [MessageEntity]?

    /// *Optional*. Inline keyboard attached to the message
    public var replyMarkup: InlineKeyboardMarkup?

    private var inputMessageContentBox: _IndirectBox<InputMessageContent>?
    /// *Optional*. Content of the message to be sent instead of the voice message
    public var inputMessageContent: InputMessageContent? {
        get { self.inputMessageContentBox?.value }
        set { self.inputMessageContentBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        type: InlineQueryResultKind = .voice,
        id: Swift.String,
        voiceFileId: Swift.String,
        title: Swift.String,
        caption: Swift.String? = nil,
        parseMode: Swift.String? = nil,
        captionEntities: [MessageEntity]? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil,
        inputMessageContent: InputMessageContent? = nil
    ) {
        self.type = type
        self.id = id
        self.voiceFileId = voiceFileId
        self.title = title
        self.caption = caption
        self.parseMode = parseMode
        self.captionEntities = captionEntities
        self.replyMarkup = replyMarkup
        self.inputMessageContentBox = inputMessageContent.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case id
        case voiceFileId = "voice_file_id"
        case title
        case caption
        case parseMode = "parse_mode"
        case captionEntities = "caption_entities"
        case replyMarkup = "reply_markup"
        case inputMessageContentBox = "input_message_content"
    }
}
