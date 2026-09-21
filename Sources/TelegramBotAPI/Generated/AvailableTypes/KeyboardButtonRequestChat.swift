// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object defines the criteria used to request a suitable chat. Information about the
/// selected chat will be shared with the bot when the corresponding button is pressed. The bot
/// will be granted requested rights in the chat if appropriate. More about requesting chats ».
public struct KeyboardButtonRequestChat: Codable, Hashable, Sendable {
    /// Signed 32-bit identifier of the request, which will be received back in the
    /// ``ChatShared`` object. Must be unique within the message.
    public var requestId: Swift.Int64

    /// Pass *True* to request a channel chat, pass *False* to request a group or a supergroup
    /// chat
    public var chatIsChannel: Swift.Bool

    /// *Optional*. Pass *True* to request a forum supergroup, pass *False* to request a
    /// non-forum chat. If not specified, no additional restrictions are applied.
    public var chatIsForum: Swift.Bool?

    /// *Optional*. Pass *True* to request a supergroup or a channel with a username, pass
    /// *False* to request a chat without a username. If not specified, no additional
    /// restrictions are applied.
    public var chatHasUsername: Swift.Bool?

    /// *Optional*. Pass *True* to request a chat owned by the user. Otherwise, no additional
    /// restrictions are applied.
    public var chatIsCreated: Swift.Bool?

    private var userAdministratorRightsBox: _IndirectBox<ChatAdministratorRights>?
    /// *Optional*. A JSON-serialized object listing the required administrator rights of the
    /// user in the chat. The rights must be a superset of *bot_administrator_rights*. If not
    /// specified, no additional restrictions are applied.
    public var userAdministratorRights: ChatAdministratorRights? {
        get { self.userAdministratorRightsBox?.value }
        set { self.userAdministratorRightsBox = newValue.map(_IndirectBox.init) }
    }

    private var botAdministratorRightsBox: _IndirectBox<ChatAdministratorRights>?
    /// *Optional*. A JSON-serialized object listing the required administrator rights of the
    /// bot in the chat. The rights must be a subset of *user_administrator_rights*. If not
    /// specified, no additional restrictions are applied.
    public var botAdministratorRights: ChatAdministratorRights? {
        get { self.botAdministratorRightsBox?.value }
        set { self.botAdministratorRightsBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Pass *True* to request a chat with the bot as a member. Otherwise, no
    /// additional restrictions are applied.
    public var botIsMember: Swift.Bool?

    /// *Optional*. Pass *True* to request the chat's title
    public var requestTitle: Swift.Bool?

    /// *Optional*. Pass *True* to request the chat's username
    public var requestUsername: Swift.Bool?

    /// *Optional*. Pass *True* to request the chat's photo
    public var requestPhoto: Swift.Bool?

    public init(
        requestId: Swift.Int64,
        chatIsChannel: Swift.Bool,
        chatIsForum: Swift.Bool? = nil,
        chatHasUsername: Swift.Bool? = nil,
        chatIsCreated: Swift.Bool? = nil,
        userAdministratorRights: ChatAdministratorRights? = nil,
        botAdministratorRights: ChatAdministratorRights? = nil,
        botIsMember: Swift.Bool? = nil,
        requestTitle: Swift.Bool? = nil,
        requestUsername: Swift.Bool? = nil,
        requestPhoto: Swift.Bool? = nil
    ) {
        self.requestId = requestId
        self.chatIsChannel = chatIsChannel
        self.chatIsForum = chatIsForum
        self.chatHasUsername = chatHasUsername
        self.chatIsCreated = chatIsCreated
        self.userAdministratorRightsBox = userAdministratorRights.map(_IndirectBox.init)
        self.botAdministratorRightsBox = botAdministratorRights.map(_IndirectBox.init)
        self.botIsMember = botIsMember
        self.requestTitle = requestTitle
        self.requestUsername = requestUsername
        self.requestPhoto = requestPhoto
    }

    public enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case chatIsChannel = "chat_is_channel"
        case chatIsForum = "chat_is_forum"
        case chatHasUsername = "chat_has_username"
        case chatIsCreated = "chat_is_created"
        case userAdministratorRightsBox = "user_administrator_rights"
        case botAdministratorRightsBox = "bot_administrator_rights"
        case botIsMember = "bot_is_member"
        case requestTitle = "request_title"
        case requestUsername = "request_username"
        case requestPhoto = "request_photo"
    }
}
