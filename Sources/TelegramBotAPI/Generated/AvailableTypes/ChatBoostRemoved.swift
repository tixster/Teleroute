// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a boost removed from a chat.
public struct ChatBoostRemoved: Codable, Hashable, Sendable {
    private var chatBox: _IndirectBox<Chat>
    /// Chat which was boosted
    public var chat: Chat {
        get { self.chatBox.value }
        set { self.chatBox = _IndirectBox(newValue) }
    }

    /// Unique identifier of the boost
    public var boostId: Swift.String

    /// Point in time (Unix timestamp) when the boost was removed
    public var removeDate: Swift.Int64

    private var sourceBox: _IndirectBox<ChatBoostSource>
    /// Source of the removed boost
    public var source: ChatBoostSource {
        get { self.sourceBox.value }
        set { self.sourceBox = _IndirectBox(newValue) }
    }

    public init(
        chat: Chat,
        boostId: Swift.String,
        removeDate: Swift.Int64,
        source: ChatBoostSource
    ) {
        self.chatBox = _IndirectBox(chat)
        self.boostId = boostId
        self.removeDate = removeDate
        self.sourceBox = _IndirectBox(source)
    }

    public enum CodingKeys: String, CodingKey {
        case chatBox = "chat"
        case boostId = "boost_id"
        case removeDate = "remove_date"
        case sourceBox = "source"
    }
}
