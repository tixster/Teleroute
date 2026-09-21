// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents the `content` of a contact message to be sent as the result of an inline query.
public struct InputContactMessageContent: Codable, Hashable, Sendable {
    /// Contact's phone number
    public var phoneNumber: Swift.String

    /// Contact's first name
    public var firstName: Swift.String

    /// *Optional*. Contact's last name
    public var lastName: Swift.String?

    /// *Optional*. Additional data about the contact in the form of a
    /// [vCard](https://en.wikipedia.org/wiki/VCard), 0-2048 bytes
    public var vcard: Swift.String?

    public init(
        phoneNumber: Swift.String,
        firstName: Swift.String,
        lastName: Swift.String? = nil,
        vcard: Swift.String? = nil
    ) {
        self.phoneNumber = phoneNumber
        self.firstName = firstName
        self.lastName = lastName
        self.vcard = vcard
    }

    public enum CodingKeys: String, CodingKey {
        case phoneNumber = "phone_number"
        case firstName = "first_name"
        case lastName = "last_name"
        case vcard
    }
}
