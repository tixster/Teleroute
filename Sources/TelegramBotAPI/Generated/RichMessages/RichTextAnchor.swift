// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// An anchor.
public struct RichTextAnchor: Codable, Hashable, Sendable {
    /// Type of the rich text, always “anchor”
    public var type: RichTextKind

    /// The name of the anchor
    public var name: Swift.String

    public init(
        type: RichTextKind = .anchor,
        name: Swift.String
    ) {
        self.type = type
        self.name = name
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case name
    }
}
