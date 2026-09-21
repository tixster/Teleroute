// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

import Foundation
import TelegramBotAPI

public extension TelegramBotClient {
    /// Use this method when you need to tell the user that something is happening on the bot's
    /// side. The status is set for 5 seconds or less (when a message arrives from your bot,
    /// Telegram clients clear its typing status). Returns *True* on success. Example: The
    /// [ImageBot](https://t.me/imagebot) needs some time to process a request and upload the
    /// image. Instead of sending a text message along the lines of “Retrieving image, please
    /// wait…”, the bot may use `sendChatAction` with *action* = *upload_photo*. The user will
    /// see a “sending photo” status for the bot. We only recommend using this method when a
    /// response from the bot will take a **noticeable** amount of time to arrive.
    @discardableResult
    func sendChatAction(
        chatId: ChatId,
        action: ChatAction,
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendChatAction")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("action", action.rawValue)
        return try await self.perform(request)
    }

    /// Use this method to ban a user in a group, a supergroup or a channel. In the case of
    /// supergroups and channels, the user will not be able to return to the chat on their own
    /// using invite links, etc., unless `unbanned` first. The bot must be an administrator in
    /// the chat for this to work and must have the appropriate administrator rights. Returns
    /// *True* on success.
    @discardableResult
    func banChatMember(
        chatId: ChatId,
        userId: Swift.Int64,
        untilDate: Swift.Int64? = nil,
        revokeMessages: Swift.Bool? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("banChatMember")
        request.set("chat_id", chatId)
        request.set("user_id", userId)
        request.set("until_date", untilDate)
        request.set("revoke_messages", revokeMessages)
        return try await self.perform(request)
    }

    /// Use this method to unban a previously banned user in a supergroup or channel. The user
    /// will **not** return to the group or channel automatically, but will be able to join via
    /// link, etc. The bot must be an administrator for this to work. By default, this method
    /// guarantees that after the call the user is not a member of the chat, but will be able to
    /// join it. So if the user is a member of the chat they will also be **removed** from the
    /// chat. If you don't want this, use the parameter *only_if_banned*. Returns *True* on
    /// success.
    @discardableResult
    func unbanChatMember(
        chatId: ChatId,
        userId: Swift.Int64,
        onlyIfBanned: Swift.Bool? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("unbanChatMember")
        request.set("chat_id", chatId)
        request.set("user_id", userId)
        request.set("only_if_banned", onlyIfBanned)
        return try await self.perform(request)
    }

    /// Use this method to restrict a user in a supergroup. The bot must be an administrator in
    /// the supergroup for this to work and must have the appropriate administrator rights. Pass
    /// *True* for all permissions to lift restrictions from a user. Returns *True* on success.
    @discardableResult
    func restrictChatMember(
        chatId: ChatId,
        userId: Swift.Int64,
        permissions: ChatPermissions,
        useIndependentChatPermissions: Swift.Bool? = nil,
        untilDate: Swift.Int64? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("restrictChatMember")
        request.set("chat_id", chatId)
        request.set("user_id", userId)
        request.set("permissions", permissions)
        request.set("use_independent_chat_permissions", useIndependentChatPermissions)
        request.set("until_date", untilDate)
        return try await self.perform(request)
    }

    /// Use this method to promote or demote a user in a supergroup or a channel. The bot must
    /// be an administrator in the chat for this to work and must have the appropriate
    /// administrator rights. Pass *False* for all boolean parameters to demote a user. Returns
    /// *True* on success.
    @discardableResult
    func promoteChatMember(
        chatId: ChatId,
        userId: Swift.Int64,
        isAnonymous: Swift.Bool? = nil,
        canManageChat: Swift.Bool? = nil,
        canDeleteMessages: Swift.Bool? = nil,
        canManageVideoChats: Swift.Bool? = nil,
        canRestrictMembers: Swift.Bool? = nil,
        canPromoteMembers: Swift.Bool? = nil,
        canChangeInfo: Swift.Bool? = nil,
        canInviteUsers: Swift.Bool? = nil,
        canPostStories: Swift.Bool? = nil,
        canEditStories: Swift.Bool? = nil,
        canDeleteStories: Swift.Bool? = nil,
        canPostMessages: Swift.Bool? = nil,
        canEditMessages: Swift.Bool? = nil,
        canPinMessages: Swift.Bool? = nil,
        canManageTopics: Swift.Bool? = nil,
        canManageDirectMessages: Swift.Bool? = nil,
        canManageTags: Swift.Bool? = nil,
        canSendWelcomeMessages: Swift.Bool? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("promoteChatMember")
        request.set("chat_id", chatId)
        request.set("user_id", userId)
        request.set("is_anonymous", isAnonymous)
        request.set("can_manage_chat", canManageChat)
        request.set("can_delete_messages", canDeleteMessages)
        request.set("can_manage_video_chats", canManageVideoChats)
        request.set("can_restrict_members", canRestrictMembers)
        request.set("can_promote_members", canPromoteMembers)
        request.set("can_change_info", canChangeInfo)
        request.set("can_invite_users", canInviteUsers)
        request.set("can_post_stories", canPostStories)
        request.set("can_edit_stories", canEditStories)
        request.set("can_delete_stories", canDeleteStories)
        request.set("can_post_messages", canPostMessages)
        request.set("can_edit_messages", canEditMessages)
        request.set("can_pin_messages", canPinMessages)
        request.set("can_manage_topics", canManageTopics)
        request.set("can_manage_direct_messages", canManageDirectMessages)
        request.set("can_manage_tags", canManageTags)
        request.set("can_send_welcome_messages", canSendWelcomeMessages)
        return try await self.perform(request)
    }

    /// Use this method to set a custom title for an administrator in a supergroup promoted by
    /// the bot. Returns *True* on success.
    @discardableResult
    func setChatAdministratorCustomTitle(
        chatId: ChatId,
        userId: Swift.Int64,
        customTitle: Swift.String
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("setChatAdministratorCustomTitle")
        request.set("chat_id", chatId)
        request.set("user_id", userId)
        request.set("custom_title", customTitle)
        return try await self.perform(request)
    }

    /// Use this method to set a tag for a regular member in a group or a supergroup. The bot
    /// must be an administrator in the chat for this to work and must have the
    /// *can_manage_tags* administrator right. Returns *True* on success.
    @discardableResult
    func setChatMemberTag(
        chatId: ChatId,
        userId: Swift.Int64,
        tag: Swift.String? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("setChatMemberTag")
        request.set("chat_id", chatId)
        request.set("user_id", userId)
        request.set("tag", tag)
        return try await self.perform(request)
    }

    /// Use this method to ban a channel chat in a supergroup or a channel. Until the chat is
    /// `unbanned`, the owner of the banned chat won't be able to send messages on behalf of
    /// **any of their channels**. The bot must be an administrator in the supergroup or channel
    /// for this to work and must have the appropriate administrator rights. Returns *True* on
    /// success.
    @discardableResult
    func banChatSenderChat(
        chatId: ChatId,
        senderChatId: Swift.Int64
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("banChatSenderChat")
        request.set("chat_id", chatId)
        request.set("sender_chat_id", senderChatId)
        return try await self.perform(request)
    }

    /// Use this method to unban a previously banned channel chat in a supergroup or channel.
    /// The bot must be an administrator for this to work and must have the appropriate
    /// administrator rights. Returns *True* on success.
    @discardableResult
    func unbanChatSenderChat(
        chatId: ChatId,
        senderChatId: Swift.Int64
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("unbanChatSenderChat")
        request.set("chat_id", chatId)
        request.set("sender_chat_id", senderChatId)
        return try await self.perform(request)
    }

    /// Use this method to set default chat permissions for all members. The bot must be an
    /// administrator in the group or a supergroup for this to work and must have the
    /// *can_restrict_members* administrator rights. Returns *True* on success.
    @discardableResult
    func setChatPermissions(
        chatId: ChatId,
        permissions: ChatPermissions,
        useIndependentChatPermissions: Swift.Bool? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("setChatPermissions")
        request.set("chat_id", chatId)
        request.set("permissions", permissions)
        request.set("use_independent_chat_permissions", useIndependentChatPermissions)
        return try await self.perform(request)
    }

    /// Use this method to generate a new primary invite link for a chat; any previously
    /// generated primary link is revoked. The bot must be an administrator in the chat for this
    /// to work and must have the appropriate administrator rights. Returns the new invite link
    /// as *String* on success.
    @discardableResult
    func exportChatInviteLink(
        chatId: ChatId
    ) async throws -> Swift.String {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("exportChatInviteLink")
        request.set("chat_id", chatId)
        return try await self.perform(request)
    }

    /// Use this method to create an additional invite link for a chat. The bot must be an
    /// administrator in the chat for this to work and must have the appropriate administrator
    /// rights. The link can be revoked using the method `revokeChatInviteLink`. Returns the new
    /// invite link as ``ChatInviteLink`` object.
    @discardableResult
    func createChatInviteLink(
        chatId: ChatId,
        name: Swift.String? = nil,
        expireDate: Swift.Int64? = nil,
        memberLimit: Swift.Int64? = nil,
        createsJoinRequest: Swift.Bool? = nil
    ) async throws -> ChatInviteLink {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("createChatInviteLink")
        request.set("chat_id", chatId)
        request.set("name", name)
        request.set("expire_date", expireDate)
        request.set("member_limit", memberLimit)
        request.set("creates_join_request", createsJoinRequest)
        return try await self.perform(request)
    }

    /// Use this method to edit a non-primary invite link created by the bot. The bot must be an
    /// administrator in the chat for this to work and must have the appropriate administrator
    /// rights. Returns the edited invite link as a ``ChatInviteLink`` object.
    @discardableResult
    func editChatInviteLink(
        chatId: ChatId,
        inviteLink: Swift.String,
        name: Swift.String? = nil,
        expireDate: Swift.Int64? = nil,
        memberLimit: Swift.Int64? = nil,
        createsJoinRequest: Swift.Bool? = nil
    ) async throws -> ChatInviteLink {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("editChatInviteLink")
        request.set("chat_id", chatId)
        request.set("invite_link", inviteLink)
        request.set("name", name)
        request.set("expire_date", expireDate)
        request.set("member_limit", memberLimit)
        request.set("creates_join_request", createsJoinRequest)
        return try await self.perform(request)
    }

    /// Use this method to revoke an invite link created by the bot. If the primary link is
    /// revoked, a new link is automatically generated. The bot must be an administrator in the
    /// chat for this to work and must have the appropriate administrator rights. Returns the
    /// revoked invite link as ``ChatInviteLink`` object.
    @discardableResult
    func revokeChatInviteLink(
        chatId: ChatId,
        inviteLink: Swift.String
    ) async throws -> ChatInviteLink {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("revokeChatInviteLink")
        request.set("chat_id", chatId)
        request.set("invite_link", inviteLink)
        return try await self.perform(request)
    }

    /// Use this method to approve a chat join request. The bot must be an administrator in the
    /// chat for this to work and must have the *can_invite_users* administrator right. Returns
    /// *True* on success.
    @discardableResult
    func approveChatJoinRequest(
        chatId: ChatId,
        userId: Swift.Int64
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("approveChatJoinRequest")
        request.set("chat_id", chatId)
        request.set("user_id", userId)
        return try await self.perform(request)
    }

    /// Use this method to decline a chat join request. The bot must be an administrator in the
    /// chat for this to work and must have the *can_invite_users* administrator right. Returns
    /// *True* on success.
    @discardableResult
    func declineChatJoinRequest(
        chatId: ChatId,
        userId: Swift.Int64
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("declineChatJoinRequest")
        request.set("chat_id", chatId)
        request.set("user_id", userId)
        return try await self.perform(request)
    }

    /// Use this method to process a received chat join request query. Returns *True* on
    /// success.
    @discardableResult
    func answerChatJoinRequestQuery(
        chatJoinRequestQueryId: Swift.String,
        result: Swift.String
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("answerChatJoinRequestQuery")
        request.set("chat_join_request_query_id", chatJoinRequestQueryId)
        request.set("result", result)
        return try await self.perform(request)
    }

    /// Use this method to set a new profile photo for the chat. Photos can't be changed for
    /// private chats. The bot must be an administrator in the chat for this to work and must
    /// have the appropriate administrator rights. Returns *True* on success.
    @discardableResult
    func setChatPhoto(
        chatId: ChatId,
        photo: FileInput
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("setChatPhoto")
        request.set("chat_id", chatId)
        request.set("photo", photo)
        return try await self.perform(request)
    }

    /// Use this method to delete a chat photo. Photos can't be changed for private chats. The
    /// bot must be an administrator in the chat for this to work and must have the appropriate
    /// administrator rights. Returns *True* on success.
    @discardableResult
    func deleteChatPhoto(
        chatId: ChatId
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("deleteChatPhoto")
        request.set("chat_id", chatId)
        return try await self.perform(request)
    }

    /// Use this method to change the title of a chat. Titles can't be changed for private
    /// chats. The bot must be an administrator in the chat for this to work and must have the
    /// appropriate administrator rights. Returns *True* on success.
    @discardableResult
    func setChatTitle(
        chatId: ChatId,
        title: Swift.String
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("setChatTitle")
        request.set("chat_id", chatId)
        request.set("title", title)
        return try await self.perform(request)
    }

    /// Use this method to change the description of a group, a supergroup or a channel. The bot
    /// must be an administrator in the chat for this to work and must have the appropriate
    /// administrator rights. Returns *True* on success.
    @discardableResult
    func setChatDescription(
        chatId: ChatId,
        description: Swift.String? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("setChatDescription")
        request.set("chat_id", chatId)
        request.set("description", description)
        return try await self.perform(request)
    }

    /// Use this method to add a message to the list of pinned messages in a chat. In private
    /// chats and channel direct messages chats, all non-service messages can be pinned.
    /// Conversely, the bot must be an administrator with the 'can_pin_messages' right or the
    /// 'can_edit_messages' right to pin messages in groups and channels respectively. Returns
    /// *True* on success.
    @discardableResult
    func pinChatMessage(
        chatId: ChatId,
        messageId: Swift.Int64,
        businessConnectionId: Swift.String? = nil,
        disableNotification: Swift.Bool? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("pinChatMessage")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_id", messageId)
        request.set("disable_notification", disableNotification)
        return try await self.perform(request)
    }

    /// Use this method to remove a message from the list of pinned messages in a chat. In
    /// private chats and channel direct messages chats, all messages can be unpinned.
    /// Conversely, the bot must be an administrator with the 'can_pin_messages' right or the
    /// 'can_edit_messages' right to unpin messages in groups and channels respectively. Returns
    /// *True* on success.
    @discardableResult
    func unpinChatMessage(
        chatId: ChatId,
        businessConnectionId: Swift.String? = nil,
        messageId: Swift.Int64? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("unpinChatMessage")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_id", messageId)
        return try await self.perform(request)
    }

    /// Use this method to clear the list of pinned messages in a chat. In private chats and
    /// channel direct messages chats, no additional rights are required to unpin all pinned
    /// messages. Conversely, the bot must be an administrator with the 'can_pin_messages' right
    /// or the 'can_edit_messages' right to unpin all pinned messages in groups and channels
    /// respectively. Returns *True* on success.
    @discardableResult
    func unpinAllChatMessages(
        chatId: ChatId
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("unpinAllChatMessages")
        request.set("chat_id", chatId)
        return try await self.perform(request)
    }

    /// Use this method for your bot to leave a group, supergroup or channel. Returns *True* on
    /// success.
    @discardableResult
    func leaveChat(
        chatId: ChatId
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("leaveChat")
        request.set("chat_id", chatId)
        return try await self.perform(request)
    }

    /// Use this method to get up-to-date information about the chat. Returns a ``ChatFullInfo``
    /// object on success.
    @discardableResult
    func getChat(
        chatId: ChatId
    ) async throws -> ChatFullInfo {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("getChat")
        request.set("chat_id", chatId)
        return try await self.perform(request)
    }

    /// Use this method to get a list of administrators in a chat. Returns an Array of
    /// ``ChatMember`` objects.
    @discardableResult
    func getChatAdministrators(
        chatId: ChatId,
        returnBots: Swift.Bool? = nil
    ) async throws -> [ChatMember] {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("getChatAdministrators")
        request.set("chat_id", chatId)
        request.set("return_bots", returnBots)
        return try await self.perform(request)
    }

    /// Use this method to get the number of members in a chat. Returns *Integer* on success.
    @discardableResult
    func getChatMemberCount(
        chatId: ChatId
    ) async throws -> Swift.Int64 {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("getChatMemberCount")
        request.set("chat_id", chatId)
        return try await self.perform(request)
    }

    /// Use this method to get information about a member of a chat. The method is only
    /// guaranteed to work for other users if the bot is an administrator in the chat. Returns a
    /// ``ChatMember`` object on success.
    @discardableResult
    func getChatMember(
        chatId: ChatId,
        userId: Swift.Int64
    ) async throws -> ChatMember {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("getChatMember")
        request.set("chat_id", chatId)
        request.set("user_id", userId)
        return try await self.perform(request)
    }

    /// Use this method to get the last messages from the personal chat (i.e., the chat
    /// currently added to their profile) of a given user. On success, an Array of ``Message``
    /// objects is returned.
    @discardableResult
    func getUserPersonalChatMessages(
        userId: Swift.Int64,
        limit: Swift.Int64
    ) async throws -> [Message] {
        var request = TelegramRequest("getUserPersonalChatMessages")
        request.set("user_id", userId)
        request.set("limit", limit)
        return try await self.perform(request)
    }

    /// Use this method to create a topic in a forum supergroup chat or a private chat with a
    /// user. In the case of a supergroup chat the bot must be an administrator in the chat for
    /// this to work and must have the *can_manage_topics* administrator right. Returns
    /// information about the created topic as a ``ForumTopic`` object.
    @discardableResult
    func createForumTopic(
        chatId: ChatId,
        name: Swift.String,
        iconColor: Swift.Int64? = nil,
        iconCustomEmojiId: Swift.String? = nil
    ) async throws -> ForumTopic {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("createForumTopic")
        request.set("chat_id", chatId)
        request.set("name", name)
        request.set("icon_color", iconColor)
        request.set("icon_custom_emoji_id", iconCustomEmojiId)
        return try await self.perform(request)
    }

    /// Use this method to edit name and icon of a topic in a forum supergroup chat or a private
    /// chat with a user. In the case of a supergroup chat the bot must be an administrator in
    /// the chat for this to work and must have the *can_manage_topics* administrator rights,
    /// unless it is the creator of the topic. Returns *True* on success.
    @discardableResult
    func editForumTopic(
        chatId: ChatId,
        messageThreadId: Swift.Int64,
        name: Swift.String? = nil,
        iconCustomEmojiId: Swift.String? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("editForumTopic")
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("name", name)
        request.set("icon_custom_emoji_id", iconCustomEmojiId)
        return try await self.perform(request)
    }

    /// Use this method to close an open topic in a forum supergroup chat. The bot must be an
    /// administrator in the chat for this to work and must have the *can_manage_topics*
    /// administrator rights, unless it is the creator of the topic. Returns *True* on success.
    @discardableResult
    func closeForumTopic(
        chatId: ChatId,
        messageThreadId: Swift.Int64
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("closeForumTopic")
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        return try await self.perform(request)
    }

    /// Use this method to reopen a closed topic in a forum supergroup chat. The bot must be an
    /// administrator in the chat for this to work and must have the *can_manage_topics*
    /// administrator rights, unless it is the creator of the topic. Returns *True* on success.
    @discardableResult
    func reopenForumTopic(
        chatId: ChatId,
        messageThreadId: Swift.Int64
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("reopenForumTopic")
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        return try await self.perform(request)
    }

    /// Use this method to delete a forum topic along with all its messages in a forum
    /// supergroup chat or a private chat with a user. In the case of a supergroup chat the bot
    /// must be an administrator in the chat for this to work and must have the
    /// *can_delete_messages* administrator rights. Returns *True* on success.
    @discardableResult
    func deleteForumTopic(
        chatId: ChatId,
        messageThreadId: Swift.Int64
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("deleteForumTopic")
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        return try await self.perform(request)
    }

    /// Use this method to clear the list of pinned messages in a forum topic in a forum
    /// supergroup chat or a private chat with a user. In the case of a supergroup chat the bot
    /// must be an administrator in the chat for this to work and must have the
    /// *can_pin_messages* administrator right in the supergroup. Returns *True* on success.
    @discardableResult
    func unpinAllForumTopicMessages(
        chatId: ChatId,
        messageThreadId: Swift.Int64
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("unpinAllForumTopicMessages")
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        return try await self.perform(request)
    }

    /// Use this method to edit the name of the 'General' topic in a forum supergroup chat. The
    /// bot must be an administrator in the chat for this to work and must have the
    /// *can_manage_topics* administrator rights. Returns *True* on success.
    @discardableResult
    func editGeneralForumTopic(
        chatId: ChatId,
        name: Swift.String
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("editGeneralForumTopic")
        request.set("chat_id", chatId)
        request.set("name", name)
        return try await self.perform(request)
    }

    /// Use this method to close an open 'General' topic in a forum supergroup chat. The bot
    /// must be an administrator in the chat for this to work and must have the
    /// *can_manage_topics* administrator rights. Returns *True* on success.
    @discardableResult
    func closeGeneralForumTopic(
        chatId: ChatId
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("closeGeneralForumTopic")
        request.set("chat_id", chatId)
        return try await self.perform(request)
    }

    /// Use this method to reopen a closed 'General' topic in a forum supergroup chat. The bot
    /// must be an administrator in the chat for this to work and must have the
    /// *can_manage_topics* administrator rights. The topic will be automatically unhidden if it
    /// was hidden. Returns *True* on success.
    @discardableResult
    func reopenGeneralForumTopic(
        chatId: ChatId
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("reopenGeneralForumTopic")
        request.set("chat_id", chatId)
        return try await self.perform(request)
    }

    /// Use this method to hide the 'General' topic in a forum supergroup chat. The bot must be
    /// an administrator in the chat for this to work and must have the *can_manage_topics*
    /// administrator rights. The topic will be automatically closed if it was open. Returns
    /// *True* on success.
    @discardableResult
    func hideGeneralForumTopic(
        chatId: ChatId
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("hideGeneralForumTopic")
        request.set("chat_id", chatId)
        return try await self.perform(request)
    }

    /// Use this method to unhide the 'General' topic in a forum supergroup chat. The bot must
    /// be an administrator in the chat for this to work and must have the *can_manage_topics*
    /// administrator rights. Returns *True* on success.
    @discardableResult
    func unhideGeneralForumTopic(
        chatId: ChatId
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("unhideGeneralForumTopic")
        request.set("chat_id", chatId)
        return try await self.perform(request)
    }

    /// Use this method to clear the list of pinned messages in a General forum topic. The bot
    /// must be an administrator in the chat for this to work and must have the
    /// *can_pin_messages* administrator right in the supergroup. Returns *True* on success.
    @discardableResult
    func unpinAllGeneralForumTopicMessages(
        chatId: ChatId
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("unpinAllGeneralForumTopicMessages")
        request.set("chat_id", chatId)
        return try await self.perform(request)
    }

    /// Use this method to get the list of boosts added to a chat by a user. Requires
    /// administrator rights in the chat. Returns a ``UserChatBoosts`` object.
    @discardableResult
    func getUserChatBoosts(
        chatId: ChatId,
        userId: Swift.Int64
    ) async throws -> UserChatBoosts {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("getUserChatBoosts")
        request.set("chat_id", chatId)
        request.set("user_id", userId)
        return try await self.perform(request)
    }

    /// Use this method to change the bot's menu button in a private chat, or the default menu
    /// button. Returns *True* on success.
    @discardableResult
    func setChatMenuButton(
        chatId: Swift.Int64? = nil,
        menuButton: MenuButton? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId.map(ChatId.id))
        var request = TelegramRequest("setChatMenuButton")
        request.set("chat_id", chatId)
        request.set("menu_button", menuButton)
        return try await self.perform(request)
    }

    /// Use this method to get the current value of the bot's menu button in a private chat, or
    /// the default menu button. Returns ``MenuButton`` on success.
    @discardableResult
    func getChatMenuButton(
        chatId: Swift.Int64? = nil
    ) async throws -> MenuButton {
        try await self.pace(chatId: chatId.map(ChatId.id))
        var request = TelegramRequest("getChatMenuButton")
        request.set("chat_id", chatId)
        return try await self.perform(request)
    }

    /// Verifies a chat [on behalf of the
    /// organization](https://telegram.org/verify#third-party-verification) which is represented
    /// by the bot. Returns *True* on success.
    @discardableResult
    func verifyChat(
        chatId: ChatId,
        customDescription: Swift.String? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("verifyChat")
        request.set("chat_id", chatId)
        request.set("custom_description", customDescription)
        return try await self.perform(request)
    }

    /// Removes verification from a chat that is currently verified [on behalf of the
    /// organization](https://telegram.org/verify#third-party-verification) represented by the
    /// bot. Returns *True* on success.
    @discardableResult
    func removeChatVerification(
        chatId: ChatId
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("removeChatVerification")
        request.set("chat_id", chatId)
        return try await self.perform(request)
    }
}
