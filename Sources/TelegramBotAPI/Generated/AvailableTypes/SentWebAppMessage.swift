// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes an inline message sent by a Web App on behalf of a user.
public struct SentWebAppMessage: Codable, Hashable, Sendable {
    /// *Optional*. Identifier of the sent inline message. Available only if there is an inline
    /// keyboard attached to the message.
    public var inlineMessageId: Swift.String?

    public init(
        inlineMessageId: Swift.String? = nil
    ) {
        self.inlineMessageId = inlineMessageId
    }

    public enum CodingKeys: String, CodingKey {
        case inlineMessageId = "inline_message_id"
    }
}
