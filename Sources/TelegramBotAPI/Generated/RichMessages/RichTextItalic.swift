// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// An italicized text.
public struct RichTextItalic: Codable, Hashable, Sendable {
    /// Type of the rich text, always “italic”
    public var type: RichTextKind

    /// The text
    public var text: RichText

    public init(
        type: RichTextKind = .italic,
        text: RichText
    ) {
        self.type = type
        self.text = text
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
    }
}
