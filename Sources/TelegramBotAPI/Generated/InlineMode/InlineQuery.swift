// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents an incoming inline query. When the user sends an empty query, your
/// bot could return some default or trending results.
public struct InlineQuery: Codable, Hashable, Sendable {
    /// Unique identifier for this query
    public var id: Swift.String

    private var fromBox: _IndirectBox<User>
    /// Sender
    public var from: User {
        get { self.fromBox.value }
        set { self.fromBox = _IndirectBox(newValue) }
    }

    /// Text of the query (up to 256 characters)
    public var query: Swift.String

    /// Offset of the results to be returned, can be controlled by the bot
    public var offset: Swift.String

    /// *Optional*. Type of the chat from which the inline query was sent. Can be either
    /// “sender” for a private chat with the inline query sender, “private”, “group”,
    /// “supergroup”, or “channel”. The chat type should be always known for requests sent from
    /// official clients and most third-party clients, unless the request was sent from a secret
    /// chat.
    public var chatType: InlineQueryChatType?

    /// *Optional*. Sender location, only for bots that request user location
    public var location: Location?

    public init(
        id: Swift.String,
        from: User,
        query: Swift.String,
        offset: Swift.String,
        chatType: InlineQueryChatType? = nil,
        location: Location? = nil
    ) {
        self.id = id
        self.fromBox = _IndirectBox(from)
        self.query = query
        self.offset = offset
        self.chatType = chatType
        self.location = location
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case fromBox = "from"
        case query
        case offset
        case chatType = "chat_type"
        case location
    }
}
