// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents the `content` of a rich message to be sent as the result of an inline query.
public struct InputRichMessageContent: Codable, Hashable, Sendable {
    /// The message to be sent. Only previously uploaded files may be used in the message.
    public var richMessage: InputRichMessage

    public init(
        richMessage: InputRichMessage
    ) {
        self.richMessage = richMessage
    }

    public enum CodingKeys: String, CodingKey {
        case richMessage = "rich_message"
    }
}
