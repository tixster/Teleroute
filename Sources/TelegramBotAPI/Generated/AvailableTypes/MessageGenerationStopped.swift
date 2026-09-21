// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes an update about a user stopping message generation.
public struct MessageGenerationStopped: Codable, Hashable, Sendable {
    private var chatBox: _IndirectBox<Chat>
    /// Chat in which the message is generated
    public var chat: Chat {
        get { self.chatBox.value }
        set { self.chatBox = _IndirectBox(newValue) }
    }

    /// *Optional*. Unique identifier of the message thread in which the message is generated
    public var messageThreadId: Swift.Int64?

    /// Unique identifier of the message draft which was stopped
    public var draftId: Swift.Int64

    public init(
        chat: Chat,
        messageThreadId: Swift.Int64? = nil,
        draftId: Swift.Int64
    ) {
        self.chatBox = _IndirectBox(chat)
        self.messageThreadId = messageThreadId
        self.draftId = draftId
    }

    public enum CodingKeys: String, CodingKey {
        case chatBox = "chat"
        case messageThreadId = "message_thread_id"
        case draftId = "draft_id"
    }
}
