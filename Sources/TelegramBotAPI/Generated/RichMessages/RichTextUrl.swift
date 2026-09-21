// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A text with a link.
public struct RichTextUrl: Codable, Hashable, Sendable {
    /// Type of the rich text, always “url”
    public var type: RichTextKind

    /// The text
    public var text: RichText

    /// URL of the link
    public var url: Swift.String

    public init(
        type: RichTextKind = .url,
        text: RichText,
        url: Swift.String
    ) {
        self.type = type
        self.text = text
        self.url = url
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
        case url
    }
}
