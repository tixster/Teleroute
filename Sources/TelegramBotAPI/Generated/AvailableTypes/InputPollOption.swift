// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains information about one answer option in a poll to be sent.
public struct InputPollOption: Codable, Hashable, Sendable {
    /// Option text, 1-100 characters
    public var text: Swift.String

    /// *Optional*. Mode for parsing entities in the text. See formatting options for more
    /// details. Currently, only custom emoji entities are allowed.
    public var textParseMode: Swift.String?

    /// *Optional*. A JSON-serialized list of special entities that appear in the poll option
    /// text. It can be specified instead of *text_parse_mode*.
    public var textEntities: [MessageEntity]?

    private var mediaBox: _IndirectBox<InputPollOptionMedia>?
    /// *Optional*. Media added to the poll option
    public var media: InputPollOptionMedia? {
        get { self.mediaBox?.value }
        set { self.mediaBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        text: Swift.String,
        textParseMode: Swift.String? = nil,
        textEntities: [MessageEntity]? = nil,
        media: InputPollOptionMedia? = nil
    ) {
        self.text = text
        self.textParseMode = textParseMode
        self.textEntities = textEntities
        self.mediaBox = media.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case text
        case textParseMode = "text_parse_mode"
        case textEntities = "text_entities"
        case mediaBox = "media"
    }
}
