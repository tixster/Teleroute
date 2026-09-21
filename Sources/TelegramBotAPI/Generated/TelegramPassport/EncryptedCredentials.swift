// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes data required for decrypting and authenticating ``EncryptedPassportElement``. See
/// the Telegram Passport Documentation for a complete description of the data decryption and
/// authentication processes.
public struct EncryptedCredentials: Codable, Hashable, Sendable {
    /// Base64-encoded encrypted JSON-serialized data with unique user's payload, data hashes
    /// and secrets required for ``EncryptedPassportElement`` decryption and authentication
    public var data: Swift.String

    /// Base64-encoded data hash for data authentication
    public var hash: Swift.String

    /// Base64-encoded secret, encrypted with the bot's public RSA key, required for data
    /// decryption
    public var secret: Swift.String

    public init(
        data: Swift.String,
        hash: Swift.String,
        secret: Swift.String
    ) {
        self.data = data
        self.hash = hash
        self.secret = secret
    }

    public enum CodingKeys: String, CodingKey {
        case data
        case hash
        case secret
    }
}
