// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A section heading, corresponding to the HTML tags `<h1>`, `<h2>`, `<h3>`, `<h4>`, `<h5>`, or
/// `<h6>`.
public struct RichBlockSectionHeading: Codable, Hashable, Sendable {
    /// Type of the block, always “heading”
    public var type: RichBlockKind

    /// Text of the block
    public var text: RichText

    /// Relative size of the text font; 1-6, 1 is the largest, 6 is the smallest
    public var size: Swift.Int64

    public init(
        type: RichBlockKind = .heading,
        text: RichText,
        size: Swift.Int64
    ) {
        self.type = type
        self.text = text
        self.size = size
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
        case size
    }
}
