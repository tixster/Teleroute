// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes documents or other Telegram Passport elements shared with the bot by the user.
public struct EncryptedPassportElement: Codable, Hashable, Sendable {
    /// Element type. One of “personal_details”, “passport”, “driver_license”, “identity_card”,
    /// “internal_passport”, “address”, “utility_bill”, “bank_statement”, “rental_agreement”,
    /// “passport_registration”, “temporary_registration”, “phone_number”, “email”.
    public var type: EncryptedPassportElementType

    /// *Optional*. Base64-encoded encrypted Telegram Passport element data provided by the
    /// user; available only for “personal_details”, “passport”, “driver_license”,
    /// “identity_card”, “internal_passport” and “address” types. Can be decrypted and verified
    /// using the accompanying ``EncryptedCredentials``.
    public var data: Swift.String?

    /// *Optional*. User's verified phone number; available only for “phone_number” type
    public var phoneNumber: Swift.String?

    /// *Optional*. User's verified email address; available only for “email” type
    public var email: Swift.String?

    /// *Optional*. Array of encrypted files with documents provided by the user; available only
    /// for “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration” and
    /// “temporary_registration” types. Files can be decrypted and verified using the
    /// accompanying ``EncryptedCredentials``.
    public var files: [PassportFile]?

    /// *Optional*. Encrypted file with the front side of the document, provided by the user;
    /// available only for “passport”, “driver_license”, “identity_card” and
    /// “internal_passport”. The file can be decrypted and verified using the accompanying
    /// ``EncryptedCredentials``.
    public var frontSide: PassportFile?

    /// *Optional*. Encrypted file with the reverse side of the document, provided by the user;
    /// available only for “driver_license” and “identity_card”. The file can be decrypted and
    /// verified using the accompanying ``EncryptedCredentials``.
    public var reverseSide: PassportFile?

    /// *Optional*. Encrypted file with the selfie of the user holding a document, provided by
    /// the user; available if requested for “passport”, “driver_license”, “identity_card” and
    /// “internal_passport”. The file can be decrypted and verified using the accompanying
    /// ``EncryptedCredentials``.
    public var selfie: PassportFile?

    /// *Optional*. Array of encrypted files with translated versions of documents provided by
    /// the user; available if requested for “passport”, “driver_license”, “identity_card”,
    /// “internal_passport”, “utility_bill”, “bank_statement”, “rental_agreement”,
    /// “passport_registration” and “temporary_registration” types. Files can be decrypted and
    /// verified using the accompanying ``EncryptedCredentials``.
    public var translation: [PassportFile]?

    /// Base64-encoded element hash for using in ``PassportElementErrorUnspecified``
    public var hash: Swift.String

    public init(
        type: EncryptedPassportElementType,
        data: Swift.String? = nil,
        phoneNumber: Swift.String? = nil,
        email: Swift.String? = nil,
        files: [PassportFile]? = nil,
        frontSide: PassportFile? = nil,
        reverseSide: PassportFile? = nil,
        selfie: PassportFile? = nil,
        translation: [PassportFile]? = nil,
        hash: Swift.String
    ) {
        self.type = type
        self.data = data
        self.phoneNumber = phoneNumber
        self.email = email
        self.files = files
        self.frontSide = frontSide
        self.reverseSide = reverseSide
        self.selfie = selfie
        self.translation = translation
        self.hash = hash
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case data
        case phoneNumber = "phone_number"
        case email
        case files
        case frontSide = "front_side"
        case reverseSide = "reverse_side"
        case selfie
        case translation
        case hash
    }
}
