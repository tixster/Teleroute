// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a chat member that isn't currently a member of the chat, but may join it
/// themselves.
public struct ChatMemberLeft: Codable, Hashable, Sendable {
    /// The member's status in the chat, always “left”
    public var status: ChatMemberKind

    private var userBox: _IndirectBox<User>
    /// Information about the user
    public var user: User {
        get { self.userBox.value }
        set { self.userBox = _IndirectBox(newValue) }
    }

    public init(
        status: ChatMemberKind = .left,
        user: User
    ) {
        self.status = status
        self.userBox = _IndirectBox(user)
    }

    public enum CodingKeys: String, CodingKey {
        case status
        case userBox = "user"
    }
}
