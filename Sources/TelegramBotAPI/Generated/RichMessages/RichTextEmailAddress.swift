// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A text with an email address.
public struct RichTextEmailAddress: Codable, Hashable, Sendable {
    /// Type of the rich text, always “email_address”
    public var type: RichTextKind

    /// The text
    public var text: RichText

    /// The email address
    public var emailAddress: Swift.String

    public init(
        type: RichTextKind = .emailAddress,
        text: RichText,
        emailAddress: Swift.String
    ) {
        self.type = type
        self.text = text
        self.emailAddress = emailAddress
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
        case emailAddress = "email_address"
    }
}
