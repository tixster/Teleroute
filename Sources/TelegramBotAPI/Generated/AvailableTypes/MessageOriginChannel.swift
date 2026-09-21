// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The message was originally sent to a channel chat.
public struct MessageOriginChannel: Codable, Hashable, Sendable {
    /// Type of the message origin, always “channel”
    public var type: MessageOriginKind

    /// Date the message was sent originally in Unix time
    public var date: Swift.Int64

    private var chatBox: _IndirectBox<Chat>
    /// Channel chat to which the message was originally sent
    public var chat: Chat {
        get { self.chatBox.value }
        set { self.chatBox = _IndirectBox(newValue) }
    }

    /// Unique message identifier inside the chat
    public var messageId: Swift.Int64

    /// *Optional*. Signature of the original post author
    public var authorSignature: Swift.String?

    public init(
        type: MessageOriginKind = .channel,
        date: Swift.Int64,
        chat: Chat,
        messageId: Swift.Int64,
        authorSignature: Swift.String? = nil
    ) {
        self.type = type
        self.date = date
        self.chatBox = _IndirectBox(chat)
        self.messageId = messageId
        self.authorSignature = authorSignature
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case date
        case chatBox = "chat"
        case messageId = "message_id"
        case authorSignature = "author_signature"
    }
}
