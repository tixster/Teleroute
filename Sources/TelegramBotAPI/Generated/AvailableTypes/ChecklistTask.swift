// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a task in a checklist.
public struct ChecklistTask: Codable, Hashable, Sendable {
    /// Unique identifier of the task
    public var id: Swift.Int64

    /// Text of the task
    public var text: Swift.String

    /// *Optional*. Special entities that appear in the task text
    public var textEntities: [MessageEntity]?

    private var completedByUserBox: _IndirectBox<User>?
    /// *Optional*. User that completed the task; omitted if the task wasn't completed by a user
    public var completedByUser: User? {
        get { self.completedByUserBox?.value }
        set { self.completedByUserBox = newValue.map(_IndirectBox.init) }
    }

    private var completedByChatBox: _IndirectBox<Chat>?
    /// *Optional*. Chat that completed the task; omitted if the task wasn't completed by a chat
    public var completedByChat: Chat? {
        get { self.completedByChatBox?.value }
        set { self.completedByChatBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Point in time (Unix timestamp) when the task was completed; 0 if the task
    /// wasn't completed
    public var completionDate: Swift.Int64?

    public init(
        id: Swift.Int64,
        text: Swift.String,
        textEntities: [MessageEntity]? = nil,
        completedByUser: User? = nil,
        completedByChat: Chat? = nil,
        completionDate: Swift.Int64? = nil
    ) {
        self.id = id
        self.text = text
        self.textEntities = textEntities
        self.completedByUserBox = completedByUser.map(_IndirectBox.init)
        self.completedByChatBox = completedByChat.map(_IndirectBox.init)
        self.completionDate = completionDate
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case text
        case textEntities = "text_entities"
        case completedByUserBox = "completed_by_user"
        case completedByChatBox = "completed_by_chat"
        case completionDate = "completion_date"
    }
}
