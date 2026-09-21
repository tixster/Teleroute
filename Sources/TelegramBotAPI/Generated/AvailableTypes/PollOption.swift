// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains information about one answer option in a poll.
public struct PollOption: Codable, Hashable, Sendable {
    /// Unique identifier of the option, persistent on option addition and deletion
    public var persistentId: Swift.String

    /// Option text, 1-100 characters
    public var text: Swift.String

    /// *Optional*. Special entities that appear in the option *text*. Currently, only custom
    /// emoji entities are allowed in poll option texts
    public var textEntities: [MessageEntity]?

    private var mediaBox: _IndirectBox<PollMedia>?
    /// *Optional*. Media added to the poll option
    public var media: PollMedia? {
        get { self.mediaBox?.value }
        set { self.mediaBox = newValue.map(_IndirectBox.init) }
    }

    /// Number of users who voted for this option; may be 0 if unknown
    public var voterCount: Swift.Int64

    private var addedByUserBox: _IndirectBox<User>?
    /// *Optional*. User who added the option; omitted if the option wasn't added by a user
    /// after poll creation
    public var addedByUser: User? {
        get { self.addedByUserBox?.value }
        set { self.addedByUserBox = newValue.map(_IndirectBox.init) }
    }

    private var addedByChatBox: _IndirectBox<Chat>?
    /// *Optional*. Chat that added the option; omitted if the option wasn't added by a chat
    /// after poll creation
    public var addedByChat: Chat? {
        get { self.addedByChatBox?.value }
        set { self.addedByChatBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Point in time (Unix timestamp) when the option was added; omitted if the
    /// option existed in the original poll
    public var additionDate: Swift.Int64?

    public init(
        persistentId: Swift.String,
        text: Swift.String,
        textEntities: [MessageEntity]? = nil,
        media: PollMedia? = nil,
        voterCount: Swift.Int64,
        addedByUser: User? = nil,
        addedByChat: Chat? = nil,
        additionDate: Swift.Int64? = nil
    ) {
        self.persistentId = persistentId
        self.text = text
        self.textEntities = textEntities
        self.mediaBox = media.map(_IndirectBox.init)
        self.voterCount = voterCount
        self.addedByUserBox = addedByUser.map(_IndirectBox.init)
        self.addedByChatBox = addedByChat.map(_IndirectBox.init)
        self.additionDate = additionDate
    }

    public enum CodingKeys: String, CodingKey {
        case persistentId = "persistent_id"
        case text
        case textEntities = "text_entities"
        case mediaBox = "media"
        case voterCount = "voter_count"
        case addedByUserBox = "added_by_user"
        case addedByChatBox = "added_by_chat"
        case additionDate = "addition_date"
    }
}
