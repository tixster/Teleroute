// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents an issue with the selfie with a document. The error is considered resolved when
/// the file with the selfie changes.
public struct PassportElementErrorSelfie: Codable, Hashable, Sendable {
    /// Error source, must be *selfie*
    public var source: PassportElementErrorKind

    /// The section of the user's Telegram Passport which has the issue, one of “passport”,
    /// “driver_license”, “identity_card”, “internal_passport”
    public var type: PassportElementErrorFrontSideType

    /// Base64-encoded hash of the file with the selfie
    public var fileHash: Swift.String

    /// Error message
    public var message: Swift.String

    public init(
        source: PassportElementErrorKind = .selfie,
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
