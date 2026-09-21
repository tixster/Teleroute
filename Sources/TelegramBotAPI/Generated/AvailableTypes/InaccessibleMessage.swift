// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes a message that was deleted or is otherwise inaccessible to the bot.
public struct InaccessibleMessage: Codable, Hashable, Sendable {
    private var chatBox: _IndirectBox<Chat>
    /// Chat the message belonged to
    public var chat: Chat {
        get { self.chatBox.value }
        set { self.chatBox = _IndirectBox(newValue) }
    }

    /// Unique message identifier inside the chat
    public var messageId: Swift.Int64

    /// Always 0. The field can be used to differentiate regular and inaccessible messages.
    public var date: Swift.Int64

    public init(
        chat: Chat,
        messageId: Swift.Int64,
        date: Swift.Int64
    ) {
        self.chatBox = _IndirectBox(chat)
        self.messageId = messageId
        self.date = date
    }

    public enum CodingKeys: String, CodingKey {
        case chatBox = "chat"
        case messageId = "message_id"
        case date
    }
}
