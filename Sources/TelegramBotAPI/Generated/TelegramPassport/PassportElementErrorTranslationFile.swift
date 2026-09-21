// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents an issue with one of the files that constitute the translation of a document. The
/// error is considered resolved when the file changes.
public struct PassportElementErrorTranslationFile: Codable, Hashable, Sendable {
    /// Error source, must be *translation_file*
    public var source: PassportElementErrorKind

    /// Type of element of the user's Telegram Passport which has the issue, one of “passport”,
    /// “driver_license”, “identity_card”, “internal_passport”, “utility_bill”,
    /// “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
    public var type: PassportElementErrorTranslationFileType

    /// Base64-encoded file hash
    public var fileHash: Swift.String

    /// Error message
    public var message: Swift.String

    public init(
        source: PassportElementErrorKind = .translationFile,
        type: PassportElementErrorTranslationFileType,
        fileHash: Swift.String,
        message: Swift.String
    ) {
        self.source = source
        self.type = type
        self.fileHash = fileHash
        self.message = message
    }

    public enum CodingKeys: String, CodingKey {
        case source
        case type
        case fileHash = "file_hash"
        case message
    }
}
