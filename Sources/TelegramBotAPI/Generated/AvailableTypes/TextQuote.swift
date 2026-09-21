// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains information about the quoted part of a message that is replied to by
/// the given message.
public struct TextQuote: Codable, Hashable, Sendable {
    /// Text of the quoted part of a message that is replied to by the given message
    public var text: Swift.String

    /// *Optional*. Special entities that appear in the quote. Currently, only *bold*, *italic*,
    /// *underline*, *strikethrough*, *spoiler*, *custom_emoji*, and *date_time* entities are
    /// kept in quotes.
    public var entities: [MessageEntity]?

    /// Approximate quote position in the original message in UTF-16 code units as specified by
    /// the sender
    public var position: Swift.Int64

    /// *Optional*. *True*, if the quote was chosen manually by the message sender. Otherwise,
    /// the quote was added automatically by the server.
    public var isManual: Swift.Bool?

    public init(
        text: Swift.String,
        entities: [MessageEntity]? = nil,
        position: Swift.Int64,
        isManual: Swift.Bool? = nil
    ) {
        self.text = text
        self.entities = entities
        self.position = position
        self.isManual = isManual
    }

    public enum CodingKeys: String, CodingKey {
        case text
        case entities
        case position
        case isManual = "is_manual"
    }
}
