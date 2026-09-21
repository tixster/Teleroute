// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a topic of a direct messages chat.
public struct DirectMessagesTopic: Codable, Hashable, Sendable {
    /// Unique identifier of the topic. This number may have more than 32 significant bits and
    /// some programming languages may have difficulty/silent defects in interpreting it. But it
    /// has at most 52 significant bits, so a 64-bit integer or double-precision float type are
    /// safe for storing this identifier.
    public var topicId: Swift.Int64

    private var userBox: _IndirectBox<User>?
    /// *Optional*. Information about the user that created the topic. Currently, it is always
    /// present.
    public var user: User? {
        get { self.userBox?.value }
        set { self.userBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        topicId: Swift.Int64,
        user: User? = nil
    ) {
        self.topicId = topicId
        self.userBox = user.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case topicId = "topic_id"
        case userBox = "user"
    }
}
