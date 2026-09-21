// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a service message about tasks added to a checklist.
public struct ChecklistTasksAdded: Codable, Hashable, Sendable {
    private var checklistMessageBox: _IndirectBox<Message>?
    /// *Optional*. Message containing the checklist to which the tasks were added. Note that
    /// the ``Message`` object in this field will not contain the *reply_to_message* field even
    /// if it itself is a reply.
    public var checklistMessage: Message? {
        get { self.checklistMessageBox?.value }
        set { self.checklistMessageBox = newValue.map(_IndirectBox.init) }
    }

    /// List of tasks added to the checklist
    public var tasks: [ChecklistTask]

    public init(
        checklistMessage: Message? = nil,
        tasks: [ChecklistTask]
    ) {
        self.checklistMessageBox = checklistMessage.map(_IndirectBox.init)
        self.tasks = tasks
    }

    public enum CodingKeys: String, CodingKey {
        case checklistMessageBox = "checklist_message"
        case tasks
    }
}
