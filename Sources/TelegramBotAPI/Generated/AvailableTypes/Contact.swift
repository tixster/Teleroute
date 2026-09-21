// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a phone contact.
public struct Contact: Codable, Hashable, Sendable {
    /// Contact's phone number
    public var phoneNumber: Swift.String

    /// Contact's first name
    public var firstName: Swift.String

    /// *Optional*. Contact's last name
    public var lastName: Swift.String?

    /// *Optional*. Contact's user identifier in Telegram. This number may have more than 32
    /// significant bits and some programming languages may have difficulty/silent defects in
    /// interpreting it. But it has at most 52 significant bits, so a 64-bit integer or
    /// double-precision float type are safe for storing this identifier.
    public var userId: Swift.Int64?

    /// *Optional*. Additional data about the contact in the form of a
    /// [vCard](https://en.wikipedia.org/wiki/VCard)
    public var vcard: Swift.String?

    public init(
        phoneNumber: Swift.String,
        firstName: Swift.String,
        lastName: Swift.String? = nil,
        userId: Swift.Int64? = nil,
        vcard: Swift.String? = nil
    ) {
        self.phoneNumber = phoneNumber
        self.firstName = firstName
        self.lastName = lastName
        self.userId = userId
        self.vcard = vcard
    }

    public enum CodingKeys: String, CodingKey {
        case phoneNumber = "phone_number"
        case firstName = "first_name"
        case lastName = "last_name"
        case userId = "user_id"
        case vcard
    }
}
