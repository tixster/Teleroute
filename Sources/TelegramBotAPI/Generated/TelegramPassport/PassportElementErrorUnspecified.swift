// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents an issue in an unspecified place. The error is considered resolved when new data
/// is added.
public struct PassportElementErrorUnspecified: Codable, Hashable, Sendable {
    /// Error source, must be *unspecified*
    public var source: PassportElementErrorKind

    /// Type of element of the user's Telegram Passport which has the issue
    public var type: Swift.String

    /// Base64-encoded element hash
    public var elementHash: Swift.String

    /// Error message
    public var message: Swift.String

    public init(
        source: PassportElementErrorKind = .unspecified,
        type: Swift.String,
        elementHash: Swift.String,
        message: Swift.String
    ) {
        self.source = source
        self.type = type
        self.elementHash = elementHash
        self.message = message
    }

    public enum CodingKeys: String, CodingKey {
        case source
        case type
        case elementHash = "element_hash"
        case message
    }
}
