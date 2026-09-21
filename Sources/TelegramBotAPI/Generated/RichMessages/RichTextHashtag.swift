// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A hashtag.
public struct RichTextHashtag: Codable, Hashable, Sendable {
    /// Type of the rich text, always “hashtag”
    public var type: RichTextKind

    /// The text
    public var text: RichText

    /// The hashtag
    public var hashtag: Swift.String

    public init(
        type: RichTextKind = .hashtag,
        text: RichText,
        hashtag: Swift.String
    ) {
        self.type = type
        self.text = text
        self.hashtag = hashtag
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
        case hashtag
    }
}
