// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a chat.
public struct Chat: Codable, Hashable, Sendable {
    /// Unique identifier for this chat. This number may have more than 32 significant bits and
    /// some programming languages may have difficulty/silent defects in interpreting it. But it
    /// has at most 52 significant bits, so a signed 64-bit integer or double-precision float
    /// type are safe for storing this identifier.
    public var id: Swift.Int64

    /// Type of the chat, can be either “private”, “group”, “supergroup” or “channel”
    public var type: ChatType

    /// *Optional*. Title, for supergroups, channels and group chats
    public var title: Swift.String?

    /// *Optional*. Username, for private chats, supergroups and channels if available
    public var username: Swift.String?

    /// *Optional*. First name of the other party in a private chat
    public var firstName: Swift.String?

    /// *Optional*. Last name of the other party in a private chat
    public var lastName: Swift.String?

    /// *Optional*. *True*, if the supergroup chat is a forum (has
    /// [topics](https://telegram.org/blog/topics-in-groups-collectible-usernames#topics-in-groups)
    /// enabled)
    public var isForum: Swift.Bool?

    /// *Optional*. *True*, if the chat is the direct messages chat of a channel
    public var isDirectMessages: Swift.Bool?

    public init(
        id: Swift.Int64,
        type: ChatType,
        title: Swift.String? = nil,
        username: Swift.String? = nil,
        firstName: Swift.String? = nil,
        lastName: Swift.String? = nil,
        isForum: Swift.Bool? = nil,
        isDirectMessages: Swift.Bool? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.isForum = isForum
        self.isDirectMessages = isDirectMessages
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case type
        case title
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case isForum = "is_forum"
        case isDirectMessages = "is_direct_messages"
    }
}
