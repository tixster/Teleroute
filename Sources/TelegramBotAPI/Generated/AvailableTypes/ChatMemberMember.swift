// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a chat member that has no additional privileges or restrictions.
public struct ChatMemberMember: Codable, Hashable, Sendable {
    /// The member's status in the chat, always “member”
    public var status: ChatMemberKind

    /// *Optional*. Tag of the member
    public var tag: Swift.String?

    private var userBox: _IndirectBox<User>
    /// Information about the user
    public var user: User {
        get { self.userBox.value }
        set { self.userBox = _IndirectBox(newValue) }
    }

    /// *Optional*. Date when the user's subscription will expire; Unix time
    public var untilDate: Swift.Int64?

    public init(
        status: ChatMemberKind = .member,
        tag: Swift.String? = nil,
        user: User,
        untilDate: Swift.Int64? = nil
    ) {
        self.status = status
        self.tag = tag
        self.userBox = _IndirectBox(user)
        self.untilDate = untilDate
    }

    public enum CodingKeys: String, CodingKey {
        case status
        case tag
        case userBox = "user"
        case untilDate = "until_date"
    }
}
