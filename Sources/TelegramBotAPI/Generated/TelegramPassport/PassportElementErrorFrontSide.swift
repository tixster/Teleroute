// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents an issue with the front side of a document. The error is considered resolved when
/// the file with the front side of the document changes.
public struct PassportElementErrorFrontSide: Codable, Hashable, Sendable {
    /// Error source, must be *front_side*
    public var source: PassportElementErrorKind

    /// The section of the user's Telegram Passport which has the issue, one of “passport”,
    /// “driver_license”, “identity_card”, “internal_passport”
    public var type: PassportElementErrorFrontSideType

    /// Base64-encoded hash of the file with the front side of the document
    public var fileHash: Swift.String

    /// Error message
    public var message: Swift.String

    public init(
        source: PassportElementErrorKind = .frontSide,
        type: PassportElementErrorFrontSideType,
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
