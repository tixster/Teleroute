// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the access settings of a bot.
public struct BotAccessSettings: Codable, Hashable, Sendable {
    /// *True*, if only selected users can access the bot. The bot's owner can always access it.
    public var isAccessRestricted: Swift.Bool

    /// *Optional*. The list of other users who have access to the bot if the access is
    /// restricted
    public var addedUsers: [User]?

    public init(
        isAccessRestricted: Swift.Bool,
        addedUsers: [User]? = nil
    ) {
        self.isAccessRestricted = isAccessRestricted
        self.addedUsers = addedUsers
    }

    public enum CodingKeys: String, CodingKey {
        case isAccessRestricted = "is_access_restricted"
        case addedUsers = "added_users"
    }
}
