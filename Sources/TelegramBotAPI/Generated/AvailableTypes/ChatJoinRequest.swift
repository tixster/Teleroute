// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a join request sent to a chat.
public struct ChatJoinRequest: Codable, Hashable, Sendable {
    private var chatBox: _IndirectBox<Chat>
    /// Chat to which the request was sent
    public var chat: Chat {
        get { self.chatBox.value }
        set { self.chatBox = _IndirectBox(newValue) }
    }

    private var fromBox: _IndirectBox<User>
    /// User that sent the join request
    public var from: User {
        get { self.fromBox.value }
        set { self.fromBox = _IndirectBox(newValue) }
    }

    /// Identifier of a private chat with the user who sent the join request. This number may
    /// have more than 32 significant bits and some programming languages may have
    /// difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so
    /// a 64-bit integer or double-precision float type are safe for storing this identifier.
    /// The bot can use this identifier for 5 minutes to send messages until the join request is
    /// processed, assuming no other administrator contacted the user.
    public var userChatId: Swift.Int64

    /// Date the request was sent in Unix time
    public var date: Swift.Int64

    /// *Optional*. Bio of the user
    public var bio: Swift.String?

    private var inviteLinkBox: _IndirectBox<ChatInviteLink>?
    /// *Optional*. Chat invite link that was used by the user to send the join request
    public var inviteLink: ChatInviteLink? {
        get { self.inviteLinkBox?.value }
        set { self.inviteLinkBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Identifier of the join request query; for bots assigned to process join
    /// requests only. If present, then the bot must call `sendChatJoinRequestWebApp` or
    /// directly call `answerChatJoinRequestQuery` within 10 seconds.
    public var queryId: Swift.String?

    public init(
        chat: Chat,
        from: User,
        userChatId: Swift.Int64,
        date: Swift.Int64,
        bio: Swift.String? = nil,
        inviteLink: ChatInviteLink? = nil,
        queryId: Swift.String? = nil
    ) {
        self.chatBox = _IndirectBox(chat)
        self.fromBox = _IndirectBox(from)
        self.userChatId = userChatId
        self.date = date
        self.bio = bio
        self.inviteLinkBox = inviteLink.map(_IndirectBox.init)
        self.queryId = queryId
    }

    public enum CodingKeys: String, CodingKey {
        case chatBox = "chat"
        case fromBox = "from"
        case userChatId = "user_chat_id"
        case date
        case bio
        case inviteLinkBox = "invite_link"
        case queryId = "query_id"
    }
}
