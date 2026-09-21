// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes why a request was unsuccessful.
public struct ResponseParameters: Codable, Hashable, Sendable {
    /// *Optional*. The group has been migrated to a supergroup with the specified identifier.
    /// This number may have more than 32 significant bits and some programming languages may
    /// have difficulty/silent defects in interpreting it. But it has at most 52 significant
    /// bits, so a signed 64-bit integer or double-precision float type are safe for storing
    /// this identifier.
    public var migrateToChatId: Swift.Int64?

    /// *Optional*. In case of exceeding flood control, the number of seconds left to wait
    /// before the request can be repeated
    public var retryAfter: Swift.Int64?

    public init(
        migrateToChatId: Swift.Int64? = nil,
        retryAfter: Swift.Int64? = nil
    ) {
        self.migrateToChatId = migrateToChatId
        self.retryAfter = retryAfter
    }

    public enum CodingKeys: String, CodingKey {
        case migrateToChatId = "migrate_to_chat_id"
        case retryAfter = "retry_after"
    }
}
