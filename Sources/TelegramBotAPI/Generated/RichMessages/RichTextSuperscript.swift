// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A superscript text.
public struct RichTextSuperscript: Codable, Hashable, Sendable {
    /// Type of the rich text, always “superscript”
    public var type: RichTextKind

    /// The text
    public var text: RichText

    public init(
        type: RichTextKind = .superscript,
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
