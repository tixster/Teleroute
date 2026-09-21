// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a chat member that is under certain restrictions in the chat. Supergroups only.
public struct ChatMemberRestricted: Codable, Hashable, Sendable {
    /// The member's status in the chat, always “restricted”
    public var status: ChatMemberKind

    /// *Optional*. Tag of the member
    public var tag: Swift.String?

    private var userBox: _IndirectBox<User>
    /// Information about the user
    public var user: User {
        get { self.userBox.value }
        set { self.userBox = _IndirectBox(newValue) }
    }

    /// *True*, if the user is a member of the chat at the moment of the request
    public var isMember: Swift.Bool

    /// *True*, if the user is allowed to send text messages, rich messages, contacts,
    /// giveaways, giveaway winners, invoices, locations and venues
    public var canSendMessages: Swift.Bool

    /// *True*, if the user is allowed to send audios
    public var canSendAudios: Swift.Bool

    /// *True*, if the user is allowed to send documents
    public var canSendDocuments: Swift.Bool

    /// *True*, if the user is allowed to send photos
    public var canSendPhotos: Swift.Bool

    /// *True*, if the user is allowed to send videos
    public var canSendVideos: Swift.Bool

    /// *True*, if the user is allowed to send video notes
    public var canSendVideoNotes: Swift.Bool

    /// *True*, if the user is allowed to send voice notes
    public var canSendVoiceNotes: Swift.Bool

    /// *True*, if the user is allowed to send polls and checklists
    public var canSendPolls: Swift.Bool

    /// *True*, if the user is allowed to send animations, games, stickers and use inline bots
    public var canSendOtherMessages: Swift.Bool

    /// *True*, if the user is allowed to add web page previews to their messages
    public var canAddWebPagePreviews: Swift.Bool

    /// *True*, if the user is allowed to react to messages
    public var canReactToMessages: Swift.Bool

    /// *True*, if the user is allowed to edit their own tag
    public var canEditTag: Swift.Bool

    /// *True*, if the user is allowed to change the chat title, photo and other settings
    public var canChangeInfo: Swift.Bool

    /// *True*, if the user is allowed to invite new users to the chat
    public var canInviteUsers: Swift.Bool

    /// *True*, if the user is allowed to pin messages
    public var canPinMessages: Swift.Bool

    /// *True*, if the user is allowed to create forum topics
    public var canManageTopics: Swift.Bool

    /// Date when restrictions will be lifted for this user; Unix time. If 0, then the user is
    /// restricted forever.
    public var untilDate: Swift.Int64

    public init(
        status: ChatMemberKind = .restricted,
        tag: Swift.String? = nil,
        user: User,
        isMember: Swift.Bool,
        canSendMessages: Swift.Bool,
        canSendAudios: Swift.Bool,
        canSendDocuments: Swift.Bool,
        canSendPhotos: Swift.Bool,
        canSendVideos: Swift.Bool,
        canSendVideoNotes: Swift.Bool,
        canSendVoiceNotes: Swift.Bool,
        canSendPolls: Swift.Bool,
        canSendOtherMessages: Swift.Bool,
        canAddWebPagePreviews: Swift.Bool,
        canReactToMessages: Swift.Bool,
        canEditTag: Swift.Bool,
        canChangeInfo: Swift.Bool,
        canInviteUsers: Swift.Bool,
        canPinMessages: Swift.Bool,
        canManageTopics: Swift.Bool,
        untilDate: Swift.Int64
    ) {
        self.status = status
        self.tag = tag
        self.userBox = _IndirectBox(user)
        self.isMember = isMember
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
        self.untilDate = untilDate
    }

    public enum CodingKeys: String, CodingKey {
        case status
        case tag
        case userBox = "user"
        case isMember = "is_member"
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
        case untilDate = "until_date"
    }
}
