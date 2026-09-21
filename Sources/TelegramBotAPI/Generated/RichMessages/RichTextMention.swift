// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A mention by a username.
public struct RichTextMention: Codable, Hashable, Sendable {
    /// Type of the rich text, always “mention”
    public var type: RichTextKind

    /// The text
    public var text: RichText

    /// The username
    public var username: Swift.String

    public init(
        type: RichTextKind = .mention,
        text: RichText,
        username: Swift.String
    ) {
        self.type = type
        self.text = text
        self.username = username
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
        case username
    }
}
