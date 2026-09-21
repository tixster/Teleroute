// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a story.
public struct Story: Codable, Hashable, Sendable {
    private var chatBox: _IndirectBox<Chat>
    /// Chat that posted the story
    public var chat: Chat {
        get { self.chatBox.value }
        set { self.chatBox = _IndirectBox(newValue) }
    }

    /// Unique identifier for the story in the chat
    public var id: Swift.Int64

    public init(
        chat: Chat,
        id: Swift.Int64
    ) {
        self.chatBox = _IndirectBox(chat)
        self.id = id
    }

    public enum CodingKeys: String, CodingKey {
        case chatBox = "chat"
        case id
    }
}
