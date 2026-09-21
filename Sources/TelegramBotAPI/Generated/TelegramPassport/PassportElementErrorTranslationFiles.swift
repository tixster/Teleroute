// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents an issue with the translated version of a document. The error is considered
/// resolved when a file with the document translation change.
public struct PassportElementErrorTranslationFiles: Codable, Hashable, Sendable {
    /// Error source, must be *translation_files*
    public var source: PassportElementErrorKind

    /// Type of element of the user's Telegram Passport which has the issue, one of “passport”,
    /// “driver_license”, “identity_card”, “internal_passport”, “utility_bill”,
    /// “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
    public var type: PassportElementErrorTranslationFileType

    /// List of base64-encoded file hashes
    public var fileHashes: [Swift.String]

    /// Error message
    public var message: Swift.String

    public init(
        source: PassportElementErrorKind = .translationFiles,
        type: PassportElementErrorTranslationFileType,
        fileHashes: [Swift.String],
        message: Swift.String
    ) {
        self.source = source
        self.type = type
        self.fileHashes = fileHashes
        self.message = message
    }

    public enum CodingKeys: String, CodingKey {
        case source
        case type
        case fileHashes = "file_hashes"
        case message
    }
}
