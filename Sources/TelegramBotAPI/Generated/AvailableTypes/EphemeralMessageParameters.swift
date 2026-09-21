// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

public struct EphemeralMessageParameters: Codable, Hashable, Sendable {
    /// Identifier of the user who will receive the message. It is not guaranteed that the user
    /// will receive the message, especially if they are offline. See `here` for more details.
    public var receiverUserId: Swift.Int64

    /// *Optional*. Identifier of the callback query which triggered the message, if any
    public var callbackQueryId: Swift.String?

    /// *Optional*. Pass *True* if the ephemeral message must be shown in place of the original
    /// message. Must be *False* for callback queries from ephemeral messages, which must be
    /// edited using regular *editEphemeralMessage…* methods.
    public var replaceCallbackQueryMessage: Swift.Bool?

    public init(
        receiverUserId: Swift.Int64,
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
