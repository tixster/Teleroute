// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a service message about an option deleted from a poll.
public struct PollOptionDeleted: Codable, Hashable, Sendable {
    /// *Optional*. Message containing the poll from which the option was deleted, if known.
    /// Note that the ``Message`` object in this field will not contain the *reply_to_message*
    /// field even if it itself is a reply.
    public var pollMessage: MaybeInaccessibleMessage?

    /// Unique identifier of the deleted option
    public var optionPersistentId: Swift.String

    /// Option text
    public var optionText: Swift.String

    /// *Optional*. Special entities that appear in the *option_text*
    public var optionTextEntities: [MessageEntity]?

    public init(
        pollMessage: MaybeInaccessibleMessage? = nil,
        optionPersistentId: Swift.String,
        optionText: Swift.String,
        optionTextEntities: [MessageEntity]? = nil
    ) {
        self.pollMessage = pollMessage
        self.optionPersistentId = optionPersistentId
        self.optionText = optionText
        self.optionTextEntities = optionTextEntities
    }

    public enum CodingKeys: String, CodingKey {
        case pollMessage = "poll_message"
        case optionPersistentId = "option_persistent_id"
        case optionText = "option_text"
        case optionTextEntities = "option_text_entities"
    }
}
