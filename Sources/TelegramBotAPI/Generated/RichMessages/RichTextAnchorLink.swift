// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A link to an anchor.
public struct RichTextAnchorLink: Codable, Hashable, Sendable {
    /// Type of the rich text, always “anchor_link”
    public var type: RichTextKind

    /// The link text
    public var text: RichText

    /// The name of the anchor. If the name is empty, then the link brings back to the top of
    /// the message.
    public var anchorName: Swift.String

    public init(
        type: RichTextKind = .anchorLink,
        text: RichText,
        anchorName: Swift.String
    ) {
        self.type = type
        self.text = text
        self.anchorName = anchorName
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
        case anchorName = "anchor_name"
    }
}
