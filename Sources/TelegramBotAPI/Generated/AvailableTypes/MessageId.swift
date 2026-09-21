// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a unique message identifier.
public struct MessageId: Codable, Hashable, Sendable {
    /// Unique message identifier. In specific instances (e.g., message containing a video sent
    /// to a big chat), the server might automatically schedule a message instead of sending it
    /// immediately. In such cases, this field will be 0 and the relevant message will be
    /// unusable until it is actually sent.
    public var messageId: Swift.Int64

    public init(
        messageId: Swift.Int64
    ) {
        self.messageId = messageId
    }

    public enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
    }
}
