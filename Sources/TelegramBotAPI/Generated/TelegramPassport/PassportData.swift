// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes Telegram Passport data shared with the bot by the user.
public struct PassportData: Codable, Hashable, Sendable {
    /// Array with information about documents and other Telegram Passport elements that was
    /// shared with the bot
    public var data: [EncryptedPassportElement]

    /// Encrypted credentials required to decrypt the data
    public var credentials: EncryptedCredentials

    public init(
        data: [EncryptedPassportElement],
        credentials: EncryptedCredentials
    ) {
        self.data = data
        self.credentials = credentials
    }

    public enum CodingKeys: String, CodingKey {
        case data
        case credentials
    }
}
