// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a task to add to a checklist.
public struct InputChecklistTask: Codable, Hashable, Sendable {
    /// Unique identifier of the task; must be positive and unique among all task identifiers
    /// currently present in the checklist
    public var id: Swift.Int64

    /// Text of the task; 1-100 characters after entities parsing
    public var text: Swift.String

    /// *Optional*. Mode for parsing entities in the text. See formatting options for more
    /// details.
    public var parseMode: Swift.String?

    /// *Optional*. List of special entities that appear in the text, which can be specified
    /// instead of parse_mode. Currently, only *bold*, *italic*, *underline*, *strikethrough*,
    /// *spoiler*, *custom_emoji*, and *date_time* entities are allowed.
    public var textEntities: [MessageEntity]?

    public init(
        id: Swift.Int64,
        text: Swift.String,
        parseMode: Swift.String? = nil,
        textEntities: [MessageEntity]? = nil
    ) {
        self.id = id
        self.text = text
        self.parseMode = parseMode
        self.textEntities = textEntities
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case text
        case parseMode = "parse_mode"
        case textEntities = "text_entities"
    }
}
