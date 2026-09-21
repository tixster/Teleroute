// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a boost added to a chat or changed.
public struct ChatBoostUpdated: Codable, Hashable, Sendable {
    private var chatBox: _IndirectBox<Chat>
    /// Chat which was boosted
    public var chat: Chat {
        get { self.chatBox.value }
        set { self.chatBox = _IndirectBox(newValue) }
    }

    private var boostBox: _IndirectBox<ChatBoost>
    /// Information about the chat boost
    public var boost: ChatBoost {
        get { self.boostBox.value }
        set { self.boostBox = _IndirectBox(newValue) }
    }

    public init(
        chat: Chat,
        boost: ChatBoost
    ) {
        self.chatBox = _IndirectBox(chat)
        self.boostBox = _IndirectBox(boost)
    }

    public enum CodingKeys: String, CodingKey {
        case chatBox = "chat"
        case boostBox = "boost"
    }
}
