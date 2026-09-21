// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A link to a reference.
public struct RichTextReferenceLink: Codable, Hashable, Sendable {
    /// Type of the rich text, always “reference_link”
    public var type: RichTextKind

    /// The link text
    public var text: RichText

    /// The name of the reference
    public var referenceName: Swift.String

    public init(
        type: RichTextKind = .referenceLink,
        text: RichText,
        referenceName: Swift.String
    ) {
        self.type = type
        self.text = text
        self.referenceName = referenceName
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
        case referenceName = "reference_name"
    }
}
