// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A text paragraph, corresponding to the HTML tag `<p>`.
public struct RichBlockParagraph: Codable, Hashable, Sendable {
    /// Type of the block, always “paragraph”
    public var type: RichBlockKind

    /// Text of the block
    public var text: RichText

    public init(
        type: RichBlockKind = .paragraph,
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
