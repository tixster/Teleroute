// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a chat member that was banned in the chat and can't return to the chat or view
/// chat messages.
public struct ChatMemberBanned: Codable, Hashable, Sendable {
    /// The member's status in the chat, always “kicked”
    public var status: ChatMemberKind

    private var userBox: _IndirectBox<User>
    /// Information about the user
    public var user: User {
        get { self.userBox.value }
        set { self.userBox = _IndirectBox(newValue) }
    }

    /// Date when restrictions will be lifted for this user; Unix time. If 0, then the user is
    /// banned forever.
    public var untilDate: Swift.Int64

    public init(
        status: ChatMemberKind = .kicked,
        user: User,
        untilDate: Swift.Int64
    ) {
        self.status = status
        self.userBox = _IndirectBox(user)
        self.untilDate = untilDate
    }

    public enum CodingKeys: String, CodingKey {
        case status
        case userBox = "user"
        case untilDate = "until_date"
    }
}
