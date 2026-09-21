// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The message was originally sent on behalf of a chat to a group chat.
public struct MessageOriginChat: Codable, Hashable, Sendable {
    /// Type of the message origin, always “chat”
    public var type: MessageOriginKind

    /// Date the message was sent originally in Unix time
    public var date: Swift.Int64

    private var senderChatBox: _IndirectBox<Chat>
    /// Chat that sent the message originally
    public var senderChat: Chat {
        get { self.senderChatBox.value }
        set { self.senderChatBox = _IndirectBox(newValue) }
    }

    /// *Optional*. For messages originally sent by an anonymous chat administrator, original
    /// message author signature
    public var authorSignature: Swift.String?

    public init(
        type: MessageOriginKind = .chat,
        date: Swift.Int64,
        senderChat: Chat,
        authorSignature: Swift.String? = nil
    ) {
        self.type = type
        self.date = date
        self.senderChatBox = _IndirectBox(senderChat)
        self.authorSignature = authorSignature
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case date
        case senderChatBox = "sender_chat"
        case authorSignature = "author_signature"
    }
}
