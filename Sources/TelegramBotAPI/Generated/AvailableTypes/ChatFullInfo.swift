// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains full information about a chat.
public struct ChatFullInfo: Codable, Hashable, Sendable {
    /// Unique identifier for this chat. This number may have more than 32 significant bits and
    /// some programming languages may have difficulty/silent defects in interpreting it. But it
    /// has at most 52 significant bits, so a signed 64-bit integer or double-precision float
    /// type are safe for storing this identifier.
    public var id: Swift.Int64

    /// Type of the chat, can be either “private”, “group”, “supergroup” or “channel”
    public var type: ChatType

    /// *Optional*. Title, for supergroups, channels and group chats
    public var title: Swift.String?

    /// *Optional*. Username, for private chats, supergroups and channels if available
    public var username: Swift.String?

    /// *Optional*. First name of the other party in a private chat
    public var firstName: Swift.String?

    /// *Optional*. Last name of the other party in a private chat
    public var lastName: Swift.String?

    /// *Optional*. *True*, if the supergroup chat is a forum (has
    /// [topics](https://telegram.org/blog/topics-in-groups-collectible-usernames#topics-in-groups)
    /// enabled)
    public var isForum: Swift.Bool?

    /// *Optional*. *True*, if the chat is the direct messages chat of a channel
    public var isDirectMessages: Swift.Bool?

    /// Identifier of the accent color for the chat name and backgrounds of the chat photo,
    /// reply header, and link preview. See accent colors for more details.
    public var accentColorId: Swift.Int64

    /// The maximum number of reactions that can be set on a message in the chat
    public var maxReactionCount: Swift.Int64

    /// *Optional*. Chat photo
    public var photo: ChatPhoto?

    /// *Optional*. If non-empty, the list of all [active chat
    /// usernames](https://telegram.org/blog/topics-in-groups-collectible-usernames#collectible-usernames);
    /// for private chats, supergroups and channels
    public var activeUsernames: [Swift.String]?

    /// *Optional*. For private chats, the date of birth of the user
    public var birthdate: Birthdate?

    private var businessIntroBox: _IndirectBox<BusinessIntro>?
    /// *Optional*. For private chats with business accounts, the intro of the business
    public var businessIntro: BusinessIntro? {
        get { self.businessIntroBox?.value }
        set { self.businessIntroBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. For private chats with business accounts, the location of the business
    public var businessLocation: BusinessLocation?

    /// *Optional*. For private chats with business accounts, the opening hours of the business
    public var businessOpeningHours: BusinessOpeningHours?

    private var personalChatBox: _IndirectBox<Chat>?
    /// *Optional*. For private chats, the personal channel of the user
    public var personalChat: Chat? {
        get { self.personalChatBox?.value }
        set { self.personalChatBox = newValue.map(_IndirectBox.init) }
    }

    private var parentChatBox: _IndirectBox<Chat>?
    /// *Optional*. Information about the corresponding channel chat; for direct messages chats
    /// only
    public var parentChat: Chat? {
        get { self.parentChatBox?.value }
        set { self.parentChatBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. List of available reactions allowed in the chat. If omitted, then all emoji
    /// reactions are allowed.
    public var availableReactions: [ReactionType]?

    /// *Optional*. Custom emoji identifier of the emoji chosen by the chat for the reply header
    /// and link preview background
    public var backgroundCustomEmojiId: Swift.String?

    /// *Optional*. Identifier of the accent color for the chat's profile background. See
    /// profile accent colors for more details.
    public var profileAccentColorId: Swift.Int64?

    /// *Optional*. Custom emoji identifier of the emoji chosen by the chat for its profile
    /// background
    public var profileBackgroundCustomEmojiId: Swift.String?

    /// *Optional*. Custom emoji identifier of the emoji status of the chat or the other party
    /// in a private chat
    public var emojiStatusCustomEmojiId: Swift.String?

    /// *Optional*. Expiration date of the emoji status of the chat or the other party in a
    /// private chat, in Unix time, if any
    public var emojiStatusExpirationDate: Swift.Int64?

    /// *Optional*. Bio of the other party in a private chat
    public var bio: Swift.String?

    /// *Optional*. *True*, if privacy settings of the other party in the private chat allows to
    /// use `tg://user?id=<user_id>` links only in chats with the user
    public var hasPrivateForwards: Swift.Bool?

    /// *Optional*. *True*, if the privacy settings of the other party restrict sending voice
    /// and video note messages in the private chat
    public var hasRestrictedVoiceAndVideoMessages: Swift.Bool?

    /// *Optional*. *True*, if users need to join the supergroup before they can send messages
    public var joinToSendMessages: Swift.Bool?

    /// *Optional*. *True*, if all users directly joining the supergroup without using an invite
    /// link need to be approved by supergroup administrators
    public var joinByRequest: Swift.Bool?

    /// *Optional*. Description, for groups, supergroups and channel chats
    public var description: Swift.String?

    /// *Optional*. Primary invite link, for groups, supergroups and channel chats
    public var inviteLink: Swift.String?

    private var pinnedMessageBox: _IndirectBox<Message>?
    /// *Optional*. The most recent pinned message (by sending date)
    public var pinnedMessage: Message? {
        get { self.pinnedMessageBox?.value }
        set { self.pinnedMessageBox = newValue.map(_IndirectBox.init) }
    }

    private var permissionsBox: _IndirectBox<ChatPermissions>?
    /// *Optional*. Default chat member permissions, for groups and supergroups
    public var permissions: ChatPermissions? {
        get { self.permissionsBox?.value }
        set { self.permissionsBox = newValue.map(_IndirectBox.init) }
    }

    /// Information about types of gifts that are accepted by the chat or by the corresponding
    /// user for private chats
    public var acceptedGiftTypes: AcceptedGiftTypes

    /// *Optional*. *True*, if paid media messages can be sent or forwarded to the channel chat.
    /// The field is available only for channel chats.
    public var canSendPaidMedia: Swift.Bool?

    /// *Optional*. For supergroups, the minimum allowed delay between consecutive messages sent
    /// by each unprivileged user; in seconds
    public var slowModeDelay: Swift.Int64?

    /// *Optional*. For supergroups, the minimum number of boosts that a non-administrator user
    /// needs to add in order to ignore slow mode and chat permissions
    public var unrestrictBoostCount: Swift.Int64?

    /// *Optional*. The time after which all messages sent to the chat will be automatically
    /// deleted; in seconds
    public var messageAutoDeleteTime: Swift.Int64?

    /// *Optional*. *True*, if aggressive anti-spam checks are enabled in the supergroup. The
    /// field is only available to chat administrators.
    public var hasAggressiveAntiSpamEnabled: Swift.Bool?

    /// *Optional*. *True*, if non-administrators can only get the list of bots and
    /// administrators in the chat
    public var hasHiddenMembers: Swift.Bool?

    /// *Optional*. *True*, if messages from the chat can't be forwarded to other chats
    public var hasProtectedContent: Swift.Bool?

    /// *Optional*. *True*, if new chat members will have access to old messages; available only
    /// to chat administrators
    public var hasVisibleHistory: Swift.Bool?

    /// *Optional*. For supergroups, name of the group sticker set
    public var stickerSetName: Swift.String?

    /// *Optional*. *True*, if the bot can change the group sticker set
    public var canSetStickerSet: Swift.Bool?

    /// *Optional*. For supergroups, the name of the group's custom emoji sticker set. Custom
    /// emoji from this set can be used by all users and bots in the group.
    public var customEmojiStickerSetName: Swift.String?

    /// *Optional*. Unique identifier for the linked chat, i.e. the discussion group identifier
    /// for a channel and vice versa; for supergroups and channel chats. This identifier may be
    /// greater than 32 bits and some programming languages may have difficulty/silent defects
    /// in interpreting it. But it is smaller than 52 bits, so a signed 64 bit integer or
    /// double-precision float type are safe for storing this identifier.
    public var linkedChatId: Swift.Int64?

    /// *Optional*. For supergroups, the location to which the supergroup is connected
    public var location: ChatLocation?

    /// *Optional*. For private chats, the rating of the user if any
    public var rating: UserRating?

    private var firstProfileAudioBox: _IndirectBox<Audio>?
    /// *Optional*. For private chats, the first audio added to the profile of the user
    public var firstProfileAudio: Audio? {
        get { self.firstProfileAudioBox?.value }
        set { self.firstProfileAudioBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. The color scheme based on a unique gift that must be used for the chat's
    /// name, message replies and link previews
    public var uniqueGiftColors: UniqueGiftColors?

    /// *Optional*. The number of Telegram Stars a general user has to pay to send a message to
    /// the chat
    public var paidMessageStarCount: Swift.Int64?

    private var guardBotBox: _IndirectBox<User>?
    /// *Optional*. The bot that processes join request queries in the chat. The field is only
    /// available to chat administrators.
    public var guardBot: User? {
        get { self.guardBotBox?.value }
        set { self.guardBotBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. The ``Community`` to which the chat belongs
    public var community: Community?

    public init(
        id: Swift.Int64,
        type: ChatType,
        title: Swift.String? = nil,
        username: Swift.String? = nil,
        firstName: Swift.String? = nil,
        lastName: Swift.String? = nil,
        isForum: Swift.Bool? = nil,
        isDirectMessages: Swift.Bool? = nil,
        accentColorId: Swift.Int64,
        maxReactionCount: Swift.Int64,
        photo: ChatPhoto? = nil,
        activeUsernames: [Swift.String]? = nil,
        birthdate: Birthdate? = nil,
        businessIntro: BusinessIntro? = nil,
        businessLocation: BusinessLocation? = nil,
        businessOpeningHours: BusinessOpeningHours? = nil,
        personalChat: Chat? = nil,
        parentChat: Chat? = nil,
        availableReactions: [ReactionType]? = nil,
        backgroundCustomEmojiId: Swift.String? = nil,
        profileAccentColorId: Swift.Int64? = nil,
        profileBackgroundCustomEmojiId: Swift.String? = nil,
        emojiStatusCustomEmojiId: Swift.String? = nil,
        emojiStatusExpirationDate: Swift.Int64? = nil,
        bio: Swift.String? = nil,
        hasPrivateForwards: Swift.Bool? = nil,
        hasRestrictedVoiceAndVideoMessages: Swift.Bool? = nil,
        joinToSendMessages: Swift.Bool? = nil,
        joinByRequest: Swift.Bool? = nil,
        description: Swift.String? = nil,
        inviteLink: Swift.String? = nil,
        pinnedMessage: Message? = nil,
        permissions: ChatPermissions? = nil,
        acceptedGiftTypes: AcceptedGiftTypes,
        canSendPaidMedia: Swift.Bool? = nil,
        slowModeDelay: Swift.Int64? = nil,
        unrestrictBoostCount: Swift.Int64? = nil,
        messageAutoDeleteTime: Swift.Int64? = nil,
        hasAggressiveAntiSpamEnabled: Swift.Bool? = nil,
        hasHiddenMembers: Swift.Bool? = nil,
        hasProtectedContent: Swift.Bool? = nil,
        hasVisibleHistory: Swift.Bool? = nil,
        stickerSetName: Swift.String? = nil,
        canSetStickerSet: Swift.Bool? = nil,
        customEmojiStickerSetName: Swift.String? = nil,
        linkedChatId: Swift.Int64? = nil,
        location: ChatLocation? = nil,
        rating: UserRating? = nil,
        firstProfileAudio: Audio? = nil,
        uniqueGiftColors: UniqueGiftColors? = nil,
        paidMessageStarCount: Swift.Int64? = nil,
        guardBot: User? = nil,
        community: Community? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.isForum = isForum
        self.isDirectMessages = isDirectMessages
        self.accentColorId = accentColorId
        self.maxReactionCount = maxReactionCount
        self.photo = photo
        self.activeUsernames = activeUsernames
        self.birthdate = birthdate
        self.businessIntroBox = businessIntro.map(_IndirectBox.init)
        self.businessLocation = businessLocation
        self.businessOpeningHours = businessOpeningHours
        self.personalChatBox = personalChat.map(_IndirectBox.init)
        self.parentChatBox = parentChat.map(_IndirectBox.init)
        self.availableReactions = availableReactions
        self.backgroundCustomEmojiId = backgroundCustomEmojiId
        self.profileAccentColorId = profileAccentColorId
        self.profileBackgroundCustomEmojiId = profileBackgroundCustomEmojiId
        self.emojiStatusCustomEmojiId = emojiStatusCustomEmojiId
        self.emojiStatusExpirationDate = emojiStatusExpirationDate
        self.bio = bio
        self.hasPrivateForwards = hasPrivateForwards
        self.hasRestrictedVoiceAndVideoMessages = hasRestrictedVoiceAndVideoMessages
        self.joinToSendMessages = joinToSendMessages
        self.joinByRequest = joinByRequest
        self.description = description
        self.inviteLink = inviteLink
        self.pinnedMessageBox = pinnedMessage.map(_IndirectBox.init)
        self.permissionsBox = permissions.map(_IndirectBox.init)
        self.acceptedGiftTypes = acceptedGiftTypes
        self.canSendPaidMedia = canSendPaidMedia
        self.slowModeDelay = slowModeDelay
        self.unrestrictBoostCount = unrestrictBoostCount
        self.messageAutoDeleteTime = messageAutoDeleteTime
        self.hasAggressiveAntiSpamEnabled = hasAggressiveAntiSpamEnabled
        self.hasHiddenMembers = hasHiddenMembers
        self.hasProtectedContent = hasProtectedContent
        self.hasVisibleHistory = hasVisibleHistory
        self.stickerSetName = stickerSetName
        self.canSetStickerSet = canSetStickerSet
        self.customEmojiStickerSetName = customEmojiStickerSetName
        self.linkedChatId = linkedChatId
        self.location = location
        self.rating = rating
        self.firstProfileAudioBox = firstProfileAudio.map(_IndirectBox.init)
        self.uniqueGiftColors = uniqueGiftColors
        self.paidMessageStarCount = paidMessageStarCount
        self.guardBotBox = guardBot.map(_IndirectBox.init)
        self.community = community
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case type
        case title
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case isForum = "is_forum"
        case isDirectMessages = "is_direct_messages"
        case accentColorId = "accent_color_id"
        case maxReactionCount = "max_reaction_count"
        case photo
        case activeUsernames = "active_usernames"
        case birthdate
        case businessIntroBox = "business_intro"
        case businessLocation = "business_location"
        case businessOpeningHours = "business_opening_hours"
        case personalChatBox = "personal_chat"
        case parentChatBox = "parent_chat"
        case availableReactions = "available_reactions"
        case backgroundCustomEmojiId = "background_custom_emoji_id"
        case profileAccentColorId = "profile_accent_color_id"
        case profileBackgroundCustomEmojiId = "profile_background_custom_emoji_id"
        case emojiStatusCustomEmojiId = "emoji_status_custom_emoji_id"
        case emojiStatusExpirationDate = "emoji_status_expiration_date"
        case bio
        case hasPrivateForwards = "has_private_forwards"
        case hasRestrictedVoiceAndVideoMessages = "has_restricted_voice_and_video_messages"
        case joinToSendMessages = "join_to_send_messages"
        case joinByRequest = "join_by_request"
        case description
        case inviteLink = "invite_link"
        case pinnedMessageBox = "pinned_message"
        case permissionsBox = "permissions"
        case acceptedGiftTypes = "accepted_gift_types"
        case canSendPaidMedia = "can_send_paid_media"
        case slowModeDelay = "slow_mode_delay"
        case unrestrictBoostCount = "unrestrict_boost_count"
        case messageAutoDeleteTime = "message_auto_delete_time"
        case hasAggressiveAntiSpamEnabled = "has_aggressive_anti_spam_enabled"
        case hasHiddenMembers = "has_hidden_members"
        case hasProtectedContent = "has_protected_content"
        case hasVisibleHistory = "has_visible_history"
        case stickerSetName = "sticker_set_name"
        case canSetStickerSet = "can_set_sticker_set"
        case customEmojiStickerSetName = "custom_emoji_sticker_set_name"
        case linkedChatId = "linked_chat_id"
        case location
        case rating
        case firstProfileAudioBox = "first_profile_audio"
        case uniqueGiftColors = "unique_gift_colors"
        case paidMessageStarCount = "paid_message_star_count"
        case guardBotBox = "guard_bot"
        case community
    }
}
