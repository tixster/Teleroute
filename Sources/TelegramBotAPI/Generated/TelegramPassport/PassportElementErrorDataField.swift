// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents an issue in one of the data fields that was provided by the user. The error is
/// considered resolved when the field's value changes.
public struct PassportElementErrorDataField: Codable, Hashable, Sendable {
    /// Error source, must be *data*
    public var source: PassportElementErrorKind

    /// The section of the user's Telegram Passport which has the error, one of
    /// “personal_details”, “passport”, “driver_license”, “identity_card”, “internal_passport”,
    /// “address”
    public var type: PassportElementErrorDataFieldType

    /// Name of the data field which has the error
    public var fieldName: Swift.String

    /// Base64-encoded data hash
    public var dataHash: Swift.String

    /// Error message
    public var message: Swift.String

    public init(
        source: PassportElementErrorKind = .data,
        type: PassportElementErrorDataFieldType,
        fieldName: Swift.String,
        dataHash: Swift.String,
        message: Swift.String
    ) {
        self.source = source
        self.type = type
        self.fieldName = fieldName
        self.dataHash = dataHash
        self.message = message
    }

    public enum CodingKeys: String, CodingKey {
        case source
        case type
        case fieldName = "field_name"
        case dataHash = "data_hash"
        case message
    }
}
