// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes actions that a non-administrator user is allowed to take in a chat.
public struct ChatPermissions: Codable, Hashable, Sendable {
    /// *Optional*. *True*, if the user is allowed to send text messages, rich messages,
    /// contacts, giveaways, giveaway winners, invoices, locations and venues
    public var canSendMessages: Swift.Bool?

    /// *Optional*. *True*, if the user is allowed to send audios
    public var canSendAudios: Swift.Bool?

    /// *Optional*. *True*, if the user is allowed to send documents
    public var canSendDocuments: Swift.Bool?

    /// *Optional*. *True*, if the user is allowed to send photos
    public var canSendPhotos: Swift.Bool?

    /// *Optional*. *True*, if the user is allowed to send videos
    public var canSendVideos: Swift.Bool?

    /// *Optional*. *True*, if the user is allowed to send video notes
    public var canSendVideoNotes: Swift.Bool?

    /// *Optional*. *True*, if the user is allowed to send voice notes
    public var canSendVoiceNotes: Swift.Bool?

    /// *Optional*. *True*, if the user is allowed to send polls and checklists
    public var canSendPolls: Swift.Bool?

    /// *Optional*. *True*, if the user is allowed to send animations, games, stickers and use
    /// inline bots
    public var canSendOtherMessages: Swift.Bool?

    /// *Optional*. *True*, if the user is allowed to add web page previews to their messages
    public var canAddWebPagePreviews: Swift.Bool?

    /// *Optional*. *True*, if the user is allowed to react to messages. If omitted, defaults to
    /// the value of *can_send_messages*.
    public var canReactToMessages: Swift.Bool?

    /// *Optional*. *True*, if the user is allowed to edit their own tag. If omitted, defaults
    /// to the value of *can_pin_messages*.
    public var canEditTag: Swift.Bool?

    /// *Optional*. *True*, if the user is allowed to change the chat title, photo and other
    /// settings. Ignored in public supergroups.
    public var canChangeInfo: Swift.Bool?

    /// *Optional*. *True*, if the user is allowed to invite new users to the chat
    public var canInviteUsers: Swift.Bool?

    /// *Optional*. *True*, if the user is allowed to pin messages. Ignored in public
    /// supergroups.
    public var canPinMessages: Swift.Bool?

    /// *Optional*. *True*, if the user is allowed to create forum topics. If omitted, defaults
    /// to the value of can_pin_messages.
    public var canManageTopics: Swift.Bool?

    public init(
        canSendMessages: Swift.Bool? = nil,
        canSendAudios: Swift.Bool? = nil,
        canSendDocuments: Swift.Bool? = nil,
        canSendPhotos: Swift.Bool? = nil,
        canSendVideos: Swift.Bool? = nil,
        canSendVideoNotes: Swift.Bool? = nil,
        canSendVoiceNotes: Swift.Bool? = nil,
        canSendPolls: Swift.Bool? = nil,
        canSendOtherMessages: Swift.Bool? = nil,
        canAddWebPagePreviews: Swift.Bool? = nil,
        canReactToMessages: Swift.Bool? = nil,
        canEditTag: Swift.Bool? = nil,
        canChangeInfo: Swift.Bool? = nil,
        canInviteUsers: Swift.Bool? = nil,
        canPinMessages: Swift.Bool? = nil,
        canManageTopics: Swift.Bool? = nil
    ) {
        self.canSendMessages = canSendMessages
        self.canSendAudios = canSendAudios
        self.canSendDocuments = canSendDocuments
        self.canSendPhotos = canSendPhotos
        self.canSendVideos = canSendVideos
        self.canSendVideoNotes = canSendVideoNotes
        self.canSendVoiceNotes = canSendVoiceNotes
        self.canSendPolls = canSendPolls
        self.canSendOtherMessages = canSendOtherMessages
        self.canAddWebPagePreviews = canAddWebPagePreviews
        self.canReactToMessages = canReactToMessages
        self.canEditTag = canEditTag
        self.canChangeInfo = canChangeInfo
        self.canInviteUsers = canInviteUsers
        self.canPinMessages = canPinMessages
        self.canManageTopics = canManageTopics
    }

    public enum CodingKeys: String, CodingKey {
        case canSendMessages = "can_send_messages"
        case canSendAudios = "can_send_audios"
        case canSendDocuments = "can_send_documents"
        case canSendPhotos = "can_send_photos"
        case canSendVideos = "can_send_videos"
        case canSendVideoNotes = "can_send_video_notes"
        case canSendVoiceNotes = "can_send_voice_notes"
        case canSendPolls = "can_send_polls"
        case canSendOtherMessages = "can_send_other_messages"
        case canAddWebPagePreviews = "can_add_web_page_previews"
        case canReactToMessages = "can_react_to_messages"
        case canEditTag = "can_edit_tag"
        case canChangeInfo = "can_change_info"
        case canInviteUsers = "can_invite_users"
        case canPinMessages = "can_pin_messages"
        case canManageTopics = "can_manage_topics"
    }
}
