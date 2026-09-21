// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A preformatted text block, corresponding to the nested HTML tags `<pre>` and `<code>`.
public struct RichBlockPreformatted: Codable, Hashable, Sendable {
    /// Type of the block, always “pre”
    public var type: RichBlockKind

    /// Text of the block
    public var text: RichText

    /// *Optional*. The programming language of the text
    public var language: Swift.String?

    public init(
        type: RichBlockKind = .pre,
        text: RichText,
        language: Swift.String? = nil
    ) {
        self.type = type
        self.text = text
        self.language = language
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
        case language
    }
}
