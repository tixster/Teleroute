// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

public struct EphemeralMessageParameters: Codable, Hashable, Sendable {
    /// *Optional*. Identifier of the user who will receive the message; required unless the
    /// message is sent as an ephemeral reply to a callback query. If omitted, then the
    /// parameter *chat_id* of the method is ignored. If specified together with
    /// *callback_query_id*, then it must be the identifier of the user who pressed the button.
    /// Must be omitted for messages sent in chats where the bot isn't a member, unless the
    /// message is a reply to an ephemeral message. It is not guaranteed that the user will
    /// receive the message, especially if they are offline. See `here` for more details.
    public var receiverUserId: Swift.Int64?

    /// *Optional*. Identifier of the callback query which triggered the message, if any. If
    /// specified and *receiver_user_id* is omitted, then the message is sent as an ephemeral
    /// reply to the callback query and will be shown only to the user who pressed the button.
    /// Ephemeral replies can't be sent to callback queries from messages in channel direct
    /// messages chats. The bot must still answer the callback query using
    /// `answerCallbackQuery`.
    public var callbackQueryId: Swift.String?

    /// *Optional*. Pass *True* if the ephemeral message must be shown in place of the original
    /// message. Must be *False* for callback queries from ephemeral messages, which must be
    /// edited using regular *editEphemeralMessage…* methods.
    public var replaceCallbackQueryMessage: Swift.Bool?

    public init(
        receiverUserId: Swift.Int64? = nil,
        callbackQueryId: Swift.String? = nil,
        replaceCallbackQueryMessage: Swift.Bool? = nil
    ) {
        self.receiverUserId = receiverUserId
        self.callbackQueryId = callbackQueryId
        self.replaceCallbackQueryMessage = replaceCallbackQueryMessage
    }

    public enum CodingKeys: String, CodingKey {
        case receiverUserId = "receiver_user_id"
        case callbackQueryId = "callback_query_id"
        case replaceCallbackQueryMessage = "replace_callback_query_message"
    }
}
