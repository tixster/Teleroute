// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a checklist to create.
public struct InputChecklist: Codable, Hashable, Sendable {
    /// Title of the checklist; 1-255 characters after entities parsing
    public var title: Swift.String

    /// *Optional*. Mode for parsing entities in the title. See formatting options for more
    /// details.
    public var parseMode: Swift.String?

    /// *Optional*. List of special entities that appear in the title, which can be specified
    /// instead of parse_mode. Currently, only *bold*, *italic*, *underline*, *strikethrough*,
    /// *spoiler*, *custom_emoji*, and *date_time* entities are allowed.
    public var titleEntities: [MessageEntity]?

    /// List of 1-30 tasks in the checklist
    public var tasks: [InputChecklistTask]

    /// *Optional*. Pass *True* if other users can add tasks to the checklist
    public var othersCanAddTasks: Swift.Bool?

    /// *Optional*. Pass *True* if other users can mark tasks as done or not done in the
    /// checklist
    public var othersCanMarkTasksAsDone: Swift.Bool?

    public init(
        title: Swift.String,
        parseMode: Swift.String? = nil,
        titleEntities: [MessageEntity]? = nil,
        tasks: [InputChecklistTask],
        othersCanAddTasks: Swift.Bool? = nil,
        othersCanMarkTasksAsDone: Swift.Bool? = nil
    ) {
        self.title = title
        self.parseMode = parseMode
        self.titleEntities = titleEntities
        self.tasks = tasks
        self.othersCanAddTasks = othersCanAddTasks
        self.othersCanMarkTasksAsDone = othersCanMarkTasksAsDone
    }

    public enum CodingKeys: String, CodingKey {
        case title
        case parseMode = "parse_mode"
        case titleEntities = "title_entities"
        case tasks
        case othersCanAddTasks = "others_can_add_tasks"
        case othersCanMarkTasksAsDone = "others_can_mark_tasks_as_done"
    }
}
