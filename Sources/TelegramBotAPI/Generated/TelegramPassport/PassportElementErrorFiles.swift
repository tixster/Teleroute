// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents an issue with a list of scans. The error is considered resolved when the list of
/// files containing the scans changes.
public struct PassportElementErrorFiles: Codable, Hashable, Sendable {
    /// Error source, must be *files*
    public var source: PassportElementErrorKind

    /// The section of the user's Telegram Passport which has the issue, one of “utility_bill”,
    /// “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
    public var type: PassportElementErrorFileType

    /// List of base64-encoded file hashes
    public var fileHashes: [Swift.String]

    /// Error message
    public var message: Swift.String

    public init(
        source: PassportElementErrorKind = .files,
        type: PassportElementErrorFileType,
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
