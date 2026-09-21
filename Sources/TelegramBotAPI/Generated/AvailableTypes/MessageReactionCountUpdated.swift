// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents reaction changes on a message with anonymous reactions.
public struct MessageReactionCountUpdated: Codable, Hashable, Sendable {
    private var chatBox: _IndirectBox<Chat>
    /// The chat containing the message
    public var chat: Chat {
        get { self.chatBox.value }
        set { self.chatBox = _IndirectBox(newValue) }
    }

    /// Unique message identifier inside the chat
    public var messageId: Swift.Int64

    /// Date of the change in Unix time
    public var date: Swift.Int64

    /// List of reactions that are present on the message
    public var reactions: [ReactionCount]

    public init(
        chat: Chat,
        messageId: Swift.Int64,
        date: Swift.Int64,
        reactions: [ReactionCount]
    ) {
        self.chatBox = _IndirectBox(chat)
        self.messageId = messageId
        self.date = date
        self.reactions = reactions
    }

    public enum CodingKeys: String, CodingKey {
        case chatBox = "chat"
        case messageId = "message_id"
        case date
        case reactions
    }
}
