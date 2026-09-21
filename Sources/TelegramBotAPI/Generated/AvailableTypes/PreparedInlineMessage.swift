// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes an inline message to be sent by a user of a Mini App.
public struct PreparedInlineMessage: Codable, Hashable, Sendable {
    /// Unique identifier of the prepared message
    public var id: Swift.String

    /// Expiration date of the prepared message, in Unix time. Expired prepared messages can no
    /// longer be used.
    public var expirationDate: Swift.Int64

    public init(
        id: Swift.String,
        expirationDate: Swift.Int64
    ) {
        self.id = id
        self.expirationDate = expirationDate
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case expirationDate = "expiration_date"
    }
}
