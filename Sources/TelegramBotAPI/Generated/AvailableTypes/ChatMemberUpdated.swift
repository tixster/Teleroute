// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents changes in the status of a chat member.
public struct ChatMemberUpdated: Codable, Hashable, Sendable {
    private var chatBox: _IndirectBox<Chat>
    /// Chat the user belongs to
    public var chat: Chat {
        get { self.chatBox.value }
        set { self.chatBox = _IndirectBox(newValue) }
    }

    private var fromBox: _IndirectBox<User>
    /// Performer of the action, which resulted in the change
    public var from: User {
        get { self.fromBox.value }
        set { self.fromBox = _IndirectBox(newValue) }
    }

    /// Date the change was done in Unix time
    public var date: Swift.Int64

    private var oldChatMemberBox: _IndirectBox<ChatMember>
    /// Previous information about the chat member
    public var oldChatMember: ChatMember {
        get { self.oldChatMemberBox.value }
        set { self.oldChatMemberBox = _IndirectBox(newValue) }
    }

    private var newChatMemberBox: _IndirectBox<ChatMember>
    /// New information about the chat member
    public var newChatMember: ChatMember {
        get { self.newChatMemberBox.value }
        set { self.newChatMemberBox = _IndirectBox(newValue) }
    }

    private var inviteLinkBox: _IndirectBox<ChatInviteLink>?
    /// *Optional*. Chat invite link, which was used by the user to join the chat; for joining
    /// by invite link events only
    public var inviteLink: ChatInviteLink? {
        get { self.inviteLinkBox?.value }
        set { self.inviteLinkBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. *True*, if the user joined the chat after sending a direct join request
    /// without using an invite link and being approved by an administrator
    public var viaJoinRequest: Swift.Bool?

    /// *Optional*. *True*, if the user joined the chat via a chat folder invite link
    public var viaChatFolderInviteLink: Swift.Bool?

    public init(
        chat: Chat,
        from: User,
        date: Swift.Int64,
        oldChatMember: ChatMember,
        newChatMember: ChatMember,
        inviteLink: ChatInviteLink? = nil,
        viaJoinRequest: Swift.Bool? = nil,
        viaChatFolderInviteLink: Swift.Bool? = nil
    ) {
        self.chatBox = _IndirectBox(chat)
        self.fromBox = _IndirectBox(from)
        self.date = date
        self.oldChatMemberBox = _IndirectBox(oldChatMember)
        self.newChatMemberBox = _IndirectBox(newChatMember)
        self.inviteLinkBox = inviteLink.map(_IndirectBox.init)
        self.viaJoinRequest = viaJoinRequest
        self.viaChatFolderInviteLink = viaChatFolderInviteLink
    }

    public enum CodingKeys: String, CodingKey {
        case chatBox = "chat"
        case fromBox = "from"
        case date
        case oldChatMemberBox = "old_chat_member"
        case newChatMemberBox = "new_chat_member"
        case inviteLinkBox = "invite_link"
        case viaJoinRequest = "via_join_request"
        case viaChatFolderInviteLink = "via_chat_folder_invite_link"
    }
}
