// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a service message about checklist tasks marked as done or not done.
public struct ChecklistTasksDone: Codable, Hashable, Sendable {
    private var checklistMessageBox: _IndirectBox<Message>?
    /// *Optional*. Message containing the checklist whose tasks were marked as done or not
    /// done. Note that the ``Message`` object in this field will not contain the
    /// *reply_to_message* field even if it itself is a reply.
    public var checklistMessage: Message? {
        get { self.checklistMessageBox?.value }
        set { self.checklistMessageBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Identifiers of the tasks that were marked as done
    public var markedAsDoneTaskIds: [Swift.Int64]?

    /// *Optional*. Identifiers of the tasks that were marked as not done
    public var markedAsNotDoneTaskIds: [Swift.Int64]?

    public init(
        checklistMessage: Message? = nil,
        markedAsDoneTaskIds: [Swift.Int64]? = nil,
        markedAsNotDoneTaskIds: [Swift.Int64]? = nil
    ) {
        self.checklistMessageBox = checklistMessage.map(_IndirectBox.init)
        self.markedAsDoneTaskIds = markedAsDoneTaskIds
        self.markedAsNotDoneTaskIds = markedAsNotDoneTaskIds
    }

    public enum CodingKeys: String, CodingKey {
        case checklistMessageBox = "checklist_message"
        case markedAsDoneTaskIds = "marked_as_done_task_ids"
        case markedAsNotDoneTaskIds = "marked_as_not_done_task_ids"
    }
}
