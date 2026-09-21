// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object defines the parameters for the creation of a managed bot. Information about the
/// created bot will be shared with the bot using the update *managed_bot* and a ``Message``
/// with the field *managed_bot_created*.
public struct KeyboardButtonRequestManagedBot: Codable, Hashable, Sendable {
    /// Signed 32-bit identifier of the request. Must be unique within the message.
    public var requestId: Swift.Int64

    /// *Optional*. Suggested name for the bot
    public var suggestedName: Swift.String?

    /// *Optional*. Suggested username for the bot
    public var suggestedUsername: Swift.String?

    public init(
        requestId: Swift.Int64,
        suggestedName: Swift.String? = nil,
        suggestedUsername: Swift.String? = nil
    ) {
        self.requestId = requestId
        self.suggestedName = suggestedName
        self.suggestedUsername = suggestedUsername
    }

    public enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case suggestedName = "suggested_name"
        case suggestedUsername = "suggested_username"
    }
}
