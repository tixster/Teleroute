// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A cashtag.
public struct RichTextCashtag: Codable, Hashable, Sendable {
    /// Type of the rich text, always “cashtag”
    public var type: RichTextKind

    /// The text
    public var text: RichText

    /// The cashtag
    public var cashtag: Swift.String

    public init(
        type: RichTextKind = .cashtag,
        text: RichText,
        cashtag: Swift.String
    ) {
        self.type = type
        self.text = text
        self.cashtag = cashtag
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
        case cashtag
    }
}
