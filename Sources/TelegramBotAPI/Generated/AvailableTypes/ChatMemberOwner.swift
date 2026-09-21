// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a chat member that owns the chat and has all administrator privileges.
public struct ChatMemberOwner: Codable, Hashable, Sendable {
    /// The member's status in the chat, always “creator”
    public var status: ChatMemberKind

    private var userBox: _IndirectBox<User>
    /// Information about the user
    public var user: User {
        get { self.userBox.value }
        set { self.userBox = _IndirectBox(newValue) }
    }

    /// *True*, if the user's presence in the chat is hidden
    public var isAnonymous: Swift.Bool

    /// *Optional*. Custom title for this user
    public var customTitle: Swift.String?

    public init(
        status: ChatMemberKind = .creator,
        user: User,
        isAnonymous: Swift.Bool,
        customTitle: Swift.String? = nil
    ) {
        self.status = status
        self.userBox = _IndirectBox(user)
        self.isAnonymous = isAnonymous
        self.customTitle = customTitle
    }

    public enum CodingKeys: String, CodingKey {
        case status
        case userBox = "user"
        case isAnonymous = "is_anonymous"
        case customTitle = "custom_title"
    }
}
