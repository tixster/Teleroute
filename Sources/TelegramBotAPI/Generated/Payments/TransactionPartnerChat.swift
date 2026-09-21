// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a transaction with a chat.
public struct TransactionPartnerChat: Codable, Hashable, Sendable {
    /// Type of the transaction partner, always “chat”
    public var type: TransactionPartnerKind

    private var chatBox: _IndirectBox<Chat>
    /// Information about the chat
    public var chat: Chat {
        get { self.chatBox.value }
        set { self.chatBox = _IndirectBox(newValue) }
    }

    private var giftBox: _IndirectBox<Gift>?
    /// *Optional*. The gift sent to the chat by the bot
    public var gift: Gift? {
        get { self.giftBox?.value }
        set { self.giftBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        type: TransactionPartnerKind = .chat,
        chat: Chat,
        gift: Gift? = nil
    ) {
        self.type = type
        self.chatBox = _IndirectBox(chat)
        self.giftBox = gift.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case chatBox = "chat"
        case giftBox = "gift"
    }
}
