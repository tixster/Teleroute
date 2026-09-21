// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A text with a phone number.
public struct RichTextPhoneNumber: Codable, Hashable, Sendable {
    /// Type of the rich text, always “phone_number”
    public var type: RichTextKind

    /// The text
    public var text: RichText

    /// The phone number
    public var phoneNumber: Swift.String

    public init(
        type: RichTextKind = .phoneNumber,
        text: RichText,
        phoneNumber: Swift.String
    ) {
        self.type = type
        self.text = text
        self.phoneNumber = phoneNumber
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
        case phoneNumber = "phone_number"
    }
}
