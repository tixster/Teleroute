// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes an inline message sent by a guest bot.
public struct SentGuestMessage: Codable, Hashable, Sendable {
    /// Identifier of the sent inline message
    public var inlineMessageId: Swift.String

    public init(
        inlineMessageId: Swift.String
    ) {
        self.inlineMessageId = inlineMessageId
    }

    public enum CodingKeys: String, CodingKey {
        case inlineMessageId = "inline_message_id"
    }
}
