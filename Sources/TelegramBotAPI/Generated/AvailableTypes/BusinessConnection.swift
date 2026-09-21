// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes the connection of the bot with a business account.
public struct BusinessConnection: Codable, Hashable, Sendable {
    /// Unique identifier of the business connection
    public var id: Swift.String

    private var userBox: _IndirectBox<User>
    /// Business account user that created the business connection
    public var user: User {
        get { self.userBox.value }
        set { self.userBox = _IndirectBox(newValue) }
    }

    /// Identifier of a private chat with the user who created the business connection. This
    /// number may have more than 32 significant bits and some programming languages may have
    /// difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so
    /// a 64-bit integer or double-precision float type are safe for storing this identifier.
    public var userChatId: Swift.Int64

    /// Date the connection was established in Unix time
    public var date: Swift.Int64

    private var rightsBox: _IndirectBox<BusinessBotRights>?
    /// *Optional*. Rights of the business bot
    public var rights: BusinessBotRights? {
        get { self.rightsBox?.value }
        set { self.rightsBox = newValue.map(_IndirectBox.init) }
    }

    /// *True*, if the connection is active
    public var isEnabled: Swift.Bool

    public init(
        id: Swift.String,
        user: User,
        userChatId: Swift.Int64,
        date: Swift.Int64,
        rights: BusinessBotRights? = nil,
        isEnabled: Swift.Bool
    ) {
        self.id = id
        self.userBox = _IndirectBox(user)
        self.userChatId = userChatId
        self.date = date
        self.rightsBox = rights.map(_IndirectBox.init)
        self.isEnabled = isEnabled
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case userBox = "user"
        case userChatId = "user_chat_id"
        case date
        case rightsBox = "rights"
        case isEnabled = "is_enabled"
    }
}
