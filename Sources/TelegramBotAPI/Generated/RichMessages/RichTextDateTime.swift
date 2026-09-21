// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Formatted date and time.
public struct RichTextDateTime: Codable, Hashable, Sendable {
    /// Type of the rich text, always “date_time”
    public var type: RichTextKind

    /// The text
    public var text: RichText

    /// The Unix time associated with the entity
    public var unixTime: Swift.Int64

    /// The string that defines the formatting of the date and time. See date-time entity
    /// formatting for more details.
    public var dateTimeFormat: Swift.String

    public init(
        type: RichTextKind = .dateTime,
        text: RichText,
        unixTime: Swift.Int64,
        dateTimeFormat: Swift.String
    ) {
        self.type = type
        self.text = text
        self.unixTime = unixTime
        self.dateTimeFormat = dateTimeFormat
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
        case unixTime = "unix_time"
        case dateTimeFormat = "date_time_format"
    }
}
