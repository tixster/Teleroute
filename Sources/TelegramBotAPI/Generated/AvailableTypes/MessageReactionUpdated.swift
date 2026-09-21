// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a change of a reaction on a message performed by a user.
public struct MessageReactionUpdated: Codable, Hashable, Sendable {
    private var chatBox: _IndirectBox<Chat>
    /// The chat containing the message the user reacted to
    public var chat: Chat {
        get { self.chatBox.value }
        set { self.chatBox = _IndirectBox(newValue) }
    }

    /// Unique identifier of the message inside the chat
    public var messageId: Swift.Int64

    private var userBox: _IndirectBox<User>?
    /// *Optional*. The user that changed the reaction, if the user isn't anonymous
    public var user: User? {
        get { self.userBox?.value }
        set { self.userBox = newValue.map(_IndirectBox.init) }
    }

    private var actorChatBox: _IndirectBox<Chat>?
    /// *Optional*. The chat on behalf of which the reaction was changed, if the user is
    /// anonymous
    public var actorChat: Chat? {
        get { self.actorChatBox?.value }
        set { self.actorChatBox = newValue.map(_IndirectBox.init) }
    }

    /// Date of the change in Unix time
    public var date: Swift.Int64

    /// Previous list of reaction types that were set by the user
    public var oldReaction: [ReactionType]

    /// New list of reaction types that have been set by the user
    public var newReaction: [ReactionType]

    public init(
        chat: Chat,
        messageId: Swift.Int64,
        user: User? = nil,
        actorChat: Chat? = nil,
        date: Swift.Int64,
        oldReaction: [ReactionType],
        newReaction: [ReactionType]
    ) {
        self.chatBox = _IndirectBox(chat)
        self.messageId = messageId
        self.userBox = user.map(_IndirectBox.init)
        self.actorChatBox = actorChat.map(_IndirectBox.init)
        self.date = date
        self.oldReaction = oldReaction
        self.newReaction = newReaction
    }

    public enum CodingKeys: String, CodingKey {
        case chatBox = "chat"
        case messageId = "message_id"
        case userBox = "user"
        case actorChatBox = "actor_chat"
        case date
        case oldReaction = "old_reaction"
        case newReaction = "new_reaction"
    }
}
