// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents the rights of an administrator in a chat.
public struct ChatAdministratorRights: Codable, Hashable, Sendable {
    /// *True*, if the user's presence in the chat is hidden
    public var isAnonymous: Swift.Bool

    /// *True*, if the administrator can access the chat event log, get boost list, see hidden
    /// supergroup and channel members, report spam messages, ignore slow mode, and send
    /// messages to the chat without paying Telegram Stars. Implied by any other administrator
    /// privilege.
    public var canManageChat: Swift.Bool

    /// *True*, if the administrator can delete messages of other users
    public var canDeleteMessages: Swift.Bool

    /// *True*, if the administrator can manage video chats
    public var canManageVideoChats: Swift.Bool

    /// *True*, if the administrator can restrict, ban or unban chat members, or access
    /// supergroup statistics
    public var canRestrictMembers: Swift.Bool

    /// *True*, if the administrator can add new administrators with a subset of their own
    /// privileges or demote administrators that they have promoted, directly or indirectly
    /// (promoted by administrators that were appointed by the user)
    public var canPromoteMembers: Swift.Bool

    /// *True*, if the user is allowed to change the chat title, photo and other settings
    public var canChangeInfo: Swift.Bool

    /// *True*, if the user is allowed to invite new users to the chat
    public var canInviteUsers: Swift.Bool

    /// *True*, if the administrator can post stories to the chat
    public var canPostStories: Swift.Bool

    /// *True*, if the administrator can edit stories posted by other users, post stories to the
    /// chat page, pin chat stories, and access the chat's story archive
    public var canEditStories: Swift.Bool

    /// *True*, if the administrator can delete stories posted by other users
    public var canDeleteStories: Swift.Bool

    /// *Optional*. *True*, if the administrator can post messages in the channel, approve
    /// suggested posts, or access channel statistics; for channels only
    public var canPostMessages: Swift.Bool?

    /// *Optional*. *True*, if the administrator can edit messages of other users and can pin
    /// messages; for channels only
    public var canEditMessages: Swift.Bool?

    /// *Optional*. *True*, if the user is allowed to pin messages; for groups and supergroups
    /// only
    public var canPinMessages: Swift.Bool?

    /// *Optional*. *True*, if the user is allowed to create, rename, close, and reopen forum
    /// topics; for supergroups only
    public var canManageTopics: Swift.Bool?

    /// *Optional*. *True*, if the administrator can manage direct messages of the channel and
    /// decline suggested posts; for channels only
    public var canManageDirectMessages: Swift.Bool?

    /// *Optional*. *True*, if the administrator can edit the tags of regular members; for
    /// groups and supergroups only
    public var canManageTags: Swift.Bool?

    /// *True*, if the administrator can manage chat welcome messages or directly send them in
    /// the case of bots
    public var canSendWelcomeMessages: Swift.Bool

    public init(
        isAnonymous: Swift.Bool,
        canManageChat: Swift.Bool,
        canDeleteMessages: Swift.Bool,
        canManageVideoChats: Swift.Bool,
        canRestrictMembers: Swift.Bool,
        canPromoteMembers: Swift.Bool,
        canChangeInfo: Swift.Bool,
        canInviteUsers: Swift.Bool,
        canPostStories: Swift.Bool,
        canEditStories: Swift.Bool,
        canDeleteStories: Swift.Bool,
        canPostMessages: Swift.Bool? = nil,
        canEditMessages: Swift.Bool? = nil,
        canPinMessages: Swift.Bool? = nil,
        canManageTopics: Swift.Bool? = nil,
        canManageDirectMessages: Swift.Bool? = nil,
        canManageTags: Swift.Bool? = nil,
        canSendWelcomeMessages: Swift.Bool
    ) {
        self.isAnonymous = isAnonymous
        self.canManageChat = canManageChat
        self.canDeleteMessages = canDeleteMessages
        self.canManageVideoChats = canManageVideoChats
        self.canRestrictMembers = canRestrictMembers
        self.canPromoteMembers = canPromoteMembers
        self.canChangeInfo = canChangeInfo
        self.canInviteUsers = canInviteUsers
        self.canPostStories = canPostStories
        self.canEditStories = canEditStories
        self.canDeleteStories = canDeleteStories
        self.canPostMessages = canPostMessages
        self.canEditMessages = canEditMessages
        self.canPinMessages = canPinMessages
        self.canManageTopics = canManageTopics
        self.canManageDirectMessages = canManageDirectMessages
        self.canManageTags = canManageTags
        self.canSendWelcomeMessages = canSendWelcomeMessages
    }

    public enum CodingKeys: String, CodingKey {
        case isAnonymous = "is_anonymous"
        case canManageChat = "can_manage_chat"
        case canDeleteMessages = "can_delete_messages"
        case canManageVideoChats = "can_manage_video_chats"
        case canRestrictMembers = "can_restrict_members"
        case canPromoteMembers = "can_promote_members"
        case canChangeInfo = "can_change_info"
        case canInviteUsers = "can_invite_users"
        case canPostStories = "can_post_stories"
        case canEditStories = "can_edit_stories"
        case canDeleteStories = "can_delete_stories"
        case canPostMessages = "can_post_messages"
        case canEditMessages = "can_edit_messages"
        case canPinMessages = "can_pin_messages"
        case canManageTopics = "can_manage_topics"
        case canManageDirectMessages = "can_manage_direct_messages"
        case canManageTags = "can_manage_tags"
        case canSendWelcomeMessages = "can_send_welcome_messages"
    }
}
