// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents the rights of a business bot.
public struct BusinessBotRights: Codable, Hashable, Sendable {
    /// *Optional*. *True*, if the bot can send and edit messages in the private chats that had
    /// incoming messages in the last 24 hours
    public var canReply: Swift.Bool?

    /// *Optional*. *True*, if the bot can mark incoming private messages as read
    public var canReadMessages: Swift.Bool?

    /// *Optional*. *True*, if the bot can delete messages sent by the bot
    public var canDeleteSentMessages: Swift.Bool?

    /// *Optional*. *True*, if the bot can delete all private messages in managed chats
    public var canDeleteAllMessages: Swift.Bool?

    /// *Optional*. *True*, if the bot can edit the first and last name of the business account
    public var canEditName: Swift.Bool?

    /// *Optional*. *True*, if the bot can edit the bio of the business account
    public var canEditBio: Swift.Bool?

    /// *Optional*. *True*, if the bot can edit the profile photo of the business account
    public var canEditProfilePhoto: Swift.Bool?

    /// *Optional*. *True*, if the bot can edit the username of the business account
    public var canEditUsername: Swift.Bool?

    /// *Optional*. *True*, if the bot can change the privacy settings pertaining to gifts for
    /// the business account
    public var canChangeGiftSettings: Swift.Bool?

    /// *Optional*. *True*, if the bot can view gifts and the amount of Telegram Stars owned by
    /// the business account
    public var canViewGiftsAndStars: Swift.Bool?

    /// *Optional*. *True*, if the bot can convert regular gifts owned by the business account
    /// to Telegram Stars
    public var canConvertGiftsToStars: Swift.Bool?

    /// *Optional*. *True*, if the bot can transfer and upgrade gifts owned by the business
    /// account
    public var canTransferAndUpgradeGifts: Swift.Bool?

    /// *Optional*. *True*, if the bot can transfer Telegram Stars received by the business
    /// account to its own account, or use them to upgrade and transfer gifts
    public var canTransferStars: Swift.Bool?

    /// *Optional*. *True*, if the bot can post, edit and delete stories on behalf of the
    /// business account
    public var canManageStories: Swift.Bool?

    public init(
        canReply: Swift.Bool? = nil,
        canReadMessages: Swift.Bool? = nil,
        canDeleteSentMessages: Swift.Bool? = nil,
        canDeleteAllMessages: Swift.Bool? = nil,
        canEditName: Swift.Bool? = nil,
        canEditBio: Swift.Bool? = nil,
        canEditProfilePhoto: Swift.Bool? = nil,
        canEditUsername: Swift.Bool? = nil,
        canChangeGiftSettings: Swift.Bool? = nil,
        canViewGiftsAndStars: Swift.Bool? = nil,
        canConvertGiftsToStars: Swift.Bool? = nil,
        canTransferAndUpgradeGifts: Swift.Bool? = nil,
        canTransferStars: Swift.Bool? = nil,
        canManageStories: Swift.Bool? = nil
    ) {
        self.canReply = canReply
        self.canReadMessages = canReadMessages
        self.canDeleteSentMessages = canDeleteSentMessages
        self.canDeleteAllMessages = canDeleteAllMessages
        self.canEditName = canEditName
        self.canEditBio = canEditBio
        self.canEditProfilePhoto = canEditProfilePhoto
        self.canEditUsername = canEditUsername
        self.canChangeGiftSettings = canChangeGiftSettings
        self.canViewGiftsAndStars = canViewGiftsAndStars
        self.canConvertGiftsToStars = canConvertGiftsToStars
        self.canTransferAndUpgradeGifts = canTransferAndUpgradeGifts
        self.canTransferStars = canTransferStars
        self.canManageStories = canManageStories
    }

    public enum CodingKeys: String, CodingKey {
        case canReply = "can_reply"
        case canReadMessages = "can_read_messages"
        case canDeleteSentMessages = "can_delete_sent_messages"
        case canDeleteAllMessages = "can_delete_all_messages"
        case canEditName = "can_edit_name"
        case canEditBio = "can_edit_bio"
        case canEditProfilePhoto = "can_edit_profile_photo"
        case canEditUsername = "can_edit_username"
        case canChangeGiftSettings = "can_change_gift_settings"
        case canViewGiftsAndStars = "can_view_gifts_and_stars"
        case canConvertGiftsToStars = "can_convert_gifts_to_stars"
        case canTransferAndUpgradeGifts = "can_transfer_and_upgrade_gifts"
        case canTransferStars = "can_transfer_stars"
        case canManageStories = "can_manage_stories"
    }
}
