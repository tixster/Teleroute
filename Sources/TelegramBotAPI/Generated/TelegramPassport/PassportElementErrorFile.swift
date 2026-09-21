// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents an issue with a document scan. The error is considered resolved when the file
/// with the document scan changes.
public struct PassportElementErrorFile: Codable, Hashable, Sendable {
    /// Error source, must be *file*
    public var source: PassportElementErrorKind

    /// The section of the user's Telegram Passport which has the issue, one of “utility_bill”,
    /// “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
    public var type: PassportElementErrorFileType

    /// Base64-encoded file hash
    public var fileHash: Swift.String

    /// Error message
    public var message: Swift.String

    public init(
        source: PassportElementErrorKind = .file,
        type: PassportElementErrorFileType,
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
