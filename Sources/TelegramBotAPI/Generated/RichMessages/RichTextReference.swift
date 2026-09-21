// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A reference.
public struct RichTextReference: Codable, Hashable, Sendable {
    /// Type of the rich text, always “reference”
    public var type: RichTextKind

    /// Text of the reference
    public var text: RichText

    /// The name of the reference
    public var name: Swift.String

    public init(
        type: RichTextKind = .reference,
        text: RichText,
        name: Swift.String
    ) {
        self.type = type
        self.text = text
        self.name = name
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
        case name
    }
}
