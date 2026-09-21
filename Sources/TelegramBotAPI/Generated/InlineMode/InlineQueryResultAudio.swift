// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a link to an MP3 audio file. By default, this audio file will be sent by the
/// user. Alternatively, you can use *input_message_content* to send a message with the
/// specified content instead of the audio.
public struct InlineQueryResultAudio: Codable, Hashable, Sendable {
    /// Type of the result, must be *audio*
    public var type: InlineQueryResultKind

    /// Unique identifier for this result, 1-64 bytes
    public var id: Swift.String

    /// A valid URL for the audio file
    public var audioUrl: Swift.String

    /// Title
    public var title: Swift.String

    /// *Optional*. Caption, 0-1024 characters after entities parsing
    public var caption: Swift.String?

    /// *Optional*. Mode for parsing entities in the audio caption. See formatting options for
    /// more details.
    public var parseMode: Swift.String?

    /// *Optional*. List of special entities that appear in the caption, which can be specified
    /// instead of *parse_mode*
    public var captionEntities: [MessageEntity]?

    /// *Optional*. Performer
    public var performer: Swift.String?

    /// *Optional*. Audio duration in seconds
    public var audioDuration: Swift.Int64?

    /// *Optional*. Inline keyboard attached to the message
    public var replyMarkup: InlineKeyboardMarkup?

    private var inputMessageContentBox: _IndirectBox<InputMessageContent>?
    /// *Optional*. Content of the message to be sent instead of the audio
    public var inputMessageContent: InputMessageContent? {
        get { self.inputMessageContentBox?.value }
        set { self.inputMessageContentBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        type: InlineQueryResultKind = .audio,
        id: Swift.String,
        audioUrl: Swift.String,
        title: Swift.String,
        caption: Swift.String? = nil,
        parseMode: Swift.String? = nil,
        captionEntities: [MessageEntity]? = nil,
        performer: Swift.String? = nil,
        audioDuration: Swift.Int64? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil,
        inputMessageContent: InputMessageContent? = nil
    ) {
        self.type = type
        self.id = id
        self.audioUrl = audioUrl
        self.title = title
        self.caption = caption
        self.parseMode = parseMode
        self.captionEntities = captionEntities
        self.performer = performer
        self.audioDuration = audioDuration
        self.replyMarkup = replyMarkup
        self.inputMessageContentBox = inputMessageContent.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case id
        case audioUrl = "audio_url"
        case title
        case caption
        case parseMode = "parse_mode"
        case captionEntities = "caption_entities"
        case performer
        case audioDuration = "audio_duration"
        case replyMarkup = "reply_markup"
        case inputMessageContentBox = "input_message_content"
    }
}
