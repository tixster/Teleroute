// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents an incoming callback query from a callback button in an inline
/// keyboard. If the button that originated the query was attached to a message sent by the bot,
/// the field *message* will be present. If the button was attached to a message sent via the
/// bot (in inline mode), the field *inline_message_id* will be present. Exactly one of the
/// fields *data* or *game_short_name* will be present.
public struct CallbackQuery: Codable, Hashable, Sendable {
    /// Unique identifier for this query
    public var id: Swift.String

    private var fromBox: _IndirectBox<User>
    /// Sender
    public var from: User {
        get { self.fromBox.value }
        set { self.fromBox = _IndirectBox(newValue) }
    }

    /// *Optional*. Message sent by the bot with the callback button that originated the query
    public var message: MaybeInaccessibleMessage?

    /// *Optional*. Identifier of the message sent via the bot in inline mode, that originated
    /// the query
    public var inlineMessageId: Swift.String?

    /// Global identifier, uniquely corresponding to the chat to which the message with the
    /// callback button was sent. Useful for high scores in `games`.
    public var chatInstance: Swift.String

    /// *Optional*. Data associated with the callback button. Be aware that the message
    /// originated the query can contain no callback buttons with this data.
    public var data: Swift.String?

    /// *Optional*. Short name of a ``Game`` to be returned, serves as the unique identifier for
    /// the game
    public var gameShortName: Swift.String?

    public init(
        id: Swift.String,
        from: User,
        message: MaybeInaccessibleMessage? = nil,
        inlineMessageId: Swift.String? = nil,
        chatInstance: Swift.String,
        data: Swift.String? = nil,
        gameShortName: Swift.String? = nil
    ) {
        self.id = id
        self.fromBox = _IndirectBox(from)
        self.message = message
        self.inlineMessageId = inlineMessageId
        self.chatInstance = chatInstance
        self.data = data
        self.gameShortName = gameShortName
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case fromBox = "from"
        case message
        case inlineMessageId = "inline_message_id"
        case chatInstance = "chat_instance"
        case data
        case gameShortName = "game_short_name"
    }
}
