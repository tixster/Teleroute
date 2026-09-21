// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a Telegram user or bot.
public struct User: Codable, Hashable, Sendable {
    /// Unique identifier for this user or bot. This number may have more than 32 significant
    /// bits and some programming languages may have difficulty/silent defects in interpreting
    /// it. But it has at most 52 significant bits, so a 64-bit integer or double-precision
    /// float type are safe for storing this identifier.
    public var id: Swift.Int64

    /// *True*, if this user is a bot
    public var isBot: Swift.Bool

    /// User's or bot's first name
    public var firstName: Swift.String

    /// *Optional*. User's or bot's last name
    public var lastName: Swift.String?

    /// *Optional*. User's or bot's username
    public var username: Swift.String?

    /// *Optional*. [IETF language tag](https://en.wikipedia.org/wiki/IETF_language_tag) of the
    /// user's language
    public var languageCode: Swift.String?

    /// *Optional*. *True*, if this user is a Telegram Premium user
    public var isPremium: Swift.Bool?

    /// *Optional*. *True*, if this user added the bot to the attachment menu
    public var addedToAttachmentMenu: Swift.Bool?

    /// *Optional*. *True*, if the bot can be invited to groups. Returned only in `getMe`.
    public var canJoinGroups: Swift.Bool?

    /// *Optional*. *True*, if privacy mode is disabled for the bot. Returned only in `getMe`.
    public var canReadAllGroupMessages: Swift.Bool?

    /// *Optional*. *True*, if the bot supports guest queries from chats it is not a member of.
    /// Returned only in `getMe`.
    public var supportsGuestQueries: Swift.Bool?

    /// *Optional*. *True*, if the bot supports inline queries. Returned only in `getMe`.
    public var supportsInlineQueries: Swift.Bool?

    /// *Optional*. *True*, if the bot can be connected to a user account to manage it. Returned
    /// only in `getMe`.
    public var canConnectToBusiness: Swift.Bool?

    /// *Optional*. *True*, if the bot has a main Web App. Returned only in `getMe`.
    public var hasMainWebApp: Swift.Bool?

    /// *Optional*. *True*, if the bot has forum topic mode enabled in private chats. Returned
    /// only in `getMe`.
    public var hasTopicsEnabled: Swift.Bool?

    /// *Optional*. *True*, if the bot allows users to create and delete topics in private
    /// chats. Returned only in `getMe`.
    public var allowsUsersToCreateTopics: Swift.Bool?

    /// *Optional*. *True*, if other bots can be created to be controlled by the bot. Returned
    /// only in `getMe`.
    public var canManageBots: Swift.Bool?

    /// *Optional*. *True*, if the bot supports join request queries and can be assigned to
    /// process them. Returned only in `getMe`.
    public var supportsJoinRequestQueries: Swift.Bool?

    public init(
        id: Swift.Int64,
        isBot: Swift.Bool,
        firstName: Swift.String,
        lastName: Swift.String? = nil,
        username: Swift.String? = nil,
        languageCode: Swift.String? = nil,
        isPremium: Swift.Bool? = nil,
        addedToAttachmentMenu: Swift.Bool? = nil,
        canJoinGroups: Swift.Bool? = nil,
        canReadAllGroupMessages: Swift.Bool? = nil,
        supportsGuestQueries: Swift.Bool? = nil,
        supportsInlineQueries: Swift.Bool? = nil,
        canConnectToBusiness: Swift.Bool? = nil,
        hasMainWebApp: Swift.Bool? = nil,
        hasTopicsEnabled: Swift.Bool? = nil,
        allowsUsersToCreateTopics: Swift.Bool? = nil,
        canManageBots: Swift.Bool? = nil,
        supportsJoinRequestQueries: Swift.Bool? = nil
    ) {
        self.id = id
        self.isBot = isBot
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.languageCode = languageCode
        self.isPremium = isPremium
        self.addedToAttachmentMenu = addedToAttachmentMenu
        self.canJoinGroups = canJoinGroups
        self.canReadAllGroupMessages = canReadAllGroupMessages
        self.supportsGuestQueries = supportsGuestQueries
        self.supportsInlineQueries = supportsInlineQueries
        self.canConnectToBusiness = canConnectToBusiness
        self.hasMainWebApp = hasMainWebApp
        self.hasTopicsEnabled = hasTopicsEnabled
        self.allowsUsersToCreateTopics = allowsUsersToCreateTopics
        self.canManageBots = canManageBots
        self.supportsJoinRequestQueries = supportsJoinRequestQueries
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case isBot = "is_bot"
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case languageCode = "language_code"
        case isPremium = "is_premium"
        case addedToAttachmentMenu = "added_to_attachment_menu"
        case canJoinGroups = "can_join_groups"
        case canReadAllGroupMessages = "can_read_all_group_messages"
        case supportsGuestQueries = "supports_guest_queries"
        case supportsInlineQueries = "supports_inline_queries"
        case canConnectToBusiness = "can_connect_to_business"
        case hasMainWebApp = "has_main_web_app"
        case hasTopicsEnabled = "has_topics_enabled"
        case allowsUsersToCreateTopics = "allows_users_to_create_topics"
        case canManageBots = "can_manage_bots"
        case supportsJoinRequestQueries = "supports_join_request_queries"
    }
}
