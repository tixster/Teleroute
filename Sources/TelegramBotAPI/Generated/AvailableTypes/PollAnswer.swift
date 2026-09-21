// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents an answer of a user in a non-anonymous poll.
public struct PollAnswer: Codable, Hashable, Sendable {
    /// Unique poll identifier
    public var pollId: Swift.String

    private var voterChatBox: _IndirectBox<Chat>?
    /// *Optional*. The chat that changed the answer to the poll, if the voter is anonymous
    public var voterChat: Chat? {
        get { self.voterChatBox?.value }
        set { self.voterChatBox = newValue.map(_IndirectBox.init) }
    }

    private var userBox: _IndirectBox<User>?
    /// *Optional*. The user that changed the answer to the poll, if the voter isn't anonymous
    public var user: User? {
        get { self.userBox?.value }
        set { self.userBox = newValue.map(_IndirectBox.init) }
    }

    /// 0-based identifiers of chosen answer options. May be empty if the vote was retracted.
    public var optionIds: [Swift.Int64]

    /// Persistent identifiers of the chosen answer options. May be empty if the vote was
    /// retracted.
    public var optionPersistentIds: [Swift.String]

    public init(
        pollId: Swift.String,
        voterChat: Chat? = nil,
        user: User? = nil,
        optionIds: [Swift.Int64],
        optionPersistentIds: [Swift.String]
    ) {
        self.pollId = pollId
        self.voterChatBox = voterChat.map(_IndirectBox.init)
        self.userBox = user.map(_IndirectBox.init)
        self.optionIds = optionIds
        self.optionPersistentIds = optionPersistentIds
    }

    public enum CodingKeys: String, CodingKey {
        case pollId = "poll_id"
        case voterChatBox = "voter_chat"
        case userBox = "user"
        case optionIds = "option_ids"
        case optionPersistentIds = "option_persistent_ids"
    }
}
