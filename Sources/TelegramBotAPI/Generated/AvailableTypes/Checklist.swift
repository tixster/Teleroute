// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a checklist.
public struct Checklist: Codable, Hashable, Sendable {
    /// Title of the checklist
    public var title: Swift.String

    /// *Optional*. Special entities that appear in the checklist title
    public var titleEntities: [MessageEntity]?

    /// List of tasks in the checklist
    public var tasks: [ChecklistTask]

    /// *Optional*. *True*, if users other than the creator of the list can add tasks to the
    /// list
    public var othersCanAddTasks: Swift.Bool?

    /// *Optional*. *True*, if users other than the creator of the list can mark tasks as done
    /// or not done
    public var othersCanMarkTasksAsDone: Swift.Bool?

    public init(
        title: Swift.String,
        titleEntities: [MessageEntity]? = nil,
        tasks: [ChecklistTask],
        othersCanAddTasks: Swift.Bool? = nil,
        othersCanMarkTasksAsDone: Swift.Bool? = nil
    ) {
        self.title = title
        self.titleEntities = titleEntities
        self.tasks = tasks
        self.othersCanAddTasks = othersCanAddTasks
        self.othersCanMarkTasksAsDone = othersCanMarkTasksAsDone
    }

    public enum CodingKeys: String, CodingKey {
        case title
        case titleEntities = "title_entities"
        case tasks
        case othersCanAddTasks = "others_can_add_tasks"
        case othersCanMarkTasksAsDone = "others_can_mark_tasks_as_done"
    }
}
