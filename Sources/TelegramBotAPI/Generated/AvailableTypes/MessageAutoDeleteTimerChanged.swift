// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a service message about a change in auto-delete timer settings.
public struct MessageAutoDeleteTimerChanged: Codable, Hashable, Sendable {
    /// New auto-delete time for messages in the chat; in seconds
    public var messageAutoDeleteTime: Swift.Int64

    public init(
        messageAutoDeleteTime: Swift.Int64
    ) {
        self.messageAutoDeleteTime = messageAutoDeleteTime
    }

    public enum CodingKeys: String, CodingKey {
        case messageAutoDeleteTime = "message_auto_delete_time"
    }
}
