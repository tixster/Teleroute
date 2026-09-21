// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

import Foundation
import TelegramBotAPI

public extension TelegramBotClient {
    /// Use this method to get a list of profile pictures for a user. Returns a
    /// ``UserProfilePhotos`` object.
    @discardableResult
    func getUserProfilePhotos(
        userId: Swift.Int64,
        offset: Swift.Int64? = nil,
        limit: Swift.Int64? = nil
    ) async throws -> UserProfilePhotos {
        var request = TelegramRequest("getUserProfilePhotos")
        request.set("user_id", userId)
        request.set("offset", offset)
        request.set("limit", limit)
        return try await self.perform(request)
    }

    /// Use this method to get a list of profile audios for a user. Returns a
    /// ``UserProfileAudios`` object.
    @discardableResult
    func getUserProfileAudios(
        userId: Swift.Int64,
        offset: Swift.Int64? = nil,
        limit: Swift.Int64? = nil
    ) async throws -> UserProfileAudios {
        var request = TelegramRequest("getUserProfileAudios")
        request.set("user_id", userId)
        request.set("offset", offset)
        request.set("limit", limit)
        return try await self.perform(request)
    }

    /// Changes the emoji status for a given user that previously allowed the bot to manage
    /// their emoji status via the Mini App method requestEmojiStatusAccess. Returns *True* on
    /// success.
    @discardableResult
    func setUserEmojiStatus(
        userId: Swift.Int64,
        emojiStatusCustomEmojiId: Swift.String? = nil,
        emojiStatusExpirationDate: Swift.Int64? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setUserEmojiStatus")
        request.set("user_id", userId)
        request.set("emoji_status_custom_emoji_id", emojiStatusCustomEmojiId)
        request.set("emoji_status_expiration_date", emojiStatusExpirationDate)
        return try await self.perform(request)
    }

    /// Use this method to get basic information about a file and prepare it for downloading.
    /// For the moment, bots can download files of up to 20MB in size. On success, a ``File``
    /// object is returned. The file can then be downloaded via the link
    /// `https://api.telegram.org/file/bot<token>/<file_path>`, where `<file_path>` is taken
    /// from the response. It is guaranteed that the link will be valid for at least 1 hour.
    /// When the link expires, a new one can be requested by calling `getFile` again.
    @discardableResult
    func getFile(
        fileId: Swift.String
    ) async throws -> File {
        var request = TelegramRequest("getFile")
        request.set("file_id", fileId)
        return try await self.perform(request)
    }

    /// Use this method to send answers to callback queries sent from inline keyboards. The
    /// answer will be displayed to the user as a notification at the top of the chat screen or
    /// as an alert. On success, *True* is returned. Alternatively, the user can be redirected
    /// to the specified Game URL. For this option to work, you must first create a game for
    /// your bot via [@BotFather](https://t.me/botfather) and accept the terms. Otherwise, you
    /// may use links like `t.me/your_bot?start=XXXX` that open your bot with a parameter.
    @discardableResult
    func answerCallbackQuery(
        callbackQueryId: Swift.String,
        text: Swift.String? = nil,
        showAlert: Swift.Bool? = nil,
        url: Swift.String? = nil,
        cacheTime: Swift.Int64? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("answerCallbackQuery")
        request.set("callback_query_id", callbackQueryId)
        request.set("text", text)
        request.set("show_alert", showAlert)
        request.set("url", url)
        request.set("cache_time", cacheTime)
        return try await self.perform(request)
    }

    /// Use this method to get information about the connection of the bot with a business
    /// account. Returns a ``BusinessConnection`` object on success.
    @discardableResult
    func getBusinessConnection(
        businessConnectionId: Swift.String
    ) async throws -> BusinessConnection {
        var request = TelegramRequest("getBusinessConnection")
        request.set("business_connection_id", businessConnectionId)
        return try await self.perform(request)
    }

    /// Use this method to get the token of a managed bot. Returns the token as *String* on
    /// success.
    @discardableResult
    func getManagedBotToken(
        userId: Swift.Int64
    ) async throws -> Swift.String {
        var request = TelegramRequest("getManagedBotToken")
        request.set("user_id", userId)
        return try await self.perform(request)
    }

    /// Use this method to revoke the current token of a managed bot and generate a new one.
    /// Returns the new token as *String* on success.
    @discardableResult
    func replaceManagedBotToken(
        userId: Swift.Int64
    ) async throws -> Swift.String {
        var request = TelegramRequest("replaceManagedBotToken")
        request.set("user_id", userId)
        return try await self.perform(request)
    }

    /// Use this method to get the access settings of a managed bot. Returns a
    /// ``BotAccessSettings`` object on success.
    @discardableResult
    func getManagedBotAccessSettings(
        userId: Swift.Int64
    ) async throws -> BotAccessSettings {
        var request = TelegramRequest("getManagedBotAccessSettings")
        request.set("user_id", userId)
        return try await self.perform(request)
    }

    /// Use this method to change the access settings of a managed bot. Returns *True* on
    /// success.
    @discardableResult
    func setManagedBotAccessSettings(
        userId: Swift.Int64,
        isAccessRestricted: Swift.Bool,
        addedUserIds: [Swift.Int64]? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setManagedBotAccessSettings")
        request.set("user_id", userId)
        request.set("is_access_restricted", isAccessRestricted)
        request.set("added_user_ids", addedUserIds)
        return try await self.perform(request)
    }

    /// Use this method to change the list of the bot's commands. See this manual for more
    /// details about bot commands. Returns *True* on success.
    @discardableResult
    func setMyCommands(
        commands: [BotCommand],
        scope: BotCommandScope? = nil,
        languageCode: Swift.String? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setMyCommands")
        request.set("commands", commands)
        request.set("scope", scope)
        request.set("language_code", languageCode)
        return try await self.perform(request)
    }

    /// Use this method to get the current list of the bot's commands for the given scope and
    /// user language. Returns an Array of ``BotCommand`` objects. If commands aren't set, an
    /// empty list is returned.
    @discardableResult
    func getMyCommands(
        scope: BotCommandScope? = nil,
        languageCode: Swift.String? = nil
    ) async throws -> [BotCommand] {
        var request = TelegramRequest("getMyCommands")
        request.set("scope", scope)
        request.set("language_code", languageCode)
        return try await self.perform(request)
    }

    /// Use this method to change the bot's name. Returns *True* on success.
    @discardableResult
    func setMyName(
        name: Swift.String? = nil,
        languageCode: Swift.String? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setMyName")
        request.set("name", name)
        request.set("language_code", languageCode)
        return try await self.perform(request)
    }

    /// Use this method to get the current bot name for the given user language. Returns
    /// ``BotName`` on success.
    @discardableResult
    func getMyName(
        languageCode: Swift.String? = nil
    ) async throws -> BotName {
        var request = TelegramRequest("getMyName")
        request.set("language_code", languageCode)
        return try await self.perform(request)
    }

    /// Use this method to change the bot's description, which is shown in the chat with the bot
    /// if the chat is empty. Returns *True* on success.
    @discardableResult
    func setMyDescription(
        description: Swift.String? = nil,
        languageCode: Swift.String? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setMyDescription")
        request.set("description", description)
        request.set("language_code", languageCode)
        return try await self.perform(request)
    }

    /// Use this method to get the current bot description for the given user language. Returns
    /// ``BotDescription`` on success.
    @discardableResult
    func getMyDescription(
        languageCode: Swift.String? = nil
    ) async throws -> BotDescription {
        var request = TelegramRequest("getMyDescription")
        request.set("language_code", languageCode)
        return try await self.perform(request)
    }

    /// Use this method to change the bot's short description, which is shown on the bot's
    /// profile page and is sent together with the link when users share the bot. Returns *True*
    /// on success.
    @discardableResult
    func setMyShortDescription(
        shortDescription: Swift.String? = nil,
        languageCode: Swift.String? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setMyShortDescription")
        request.set("short_description", shortDescription)
        request.set("language_code", languageCode)
        return try await self.perform(request)
    }

    /// Use this method to get the current bot short description for the given user language.
    /// Returns ``BotShortDescription`` on success.
    @discardableResult
    func getMyShortDescription(
        languageCode: Swift.String? = nil
    ) async throws -> BotShortDescription {
        var request = TelegramRequest("getMyShortDescription")
        request.set("language_code", languageCode)
        return try await self.perform(request)
    }

    /// Changes the profile photo of the bot. Returns *True* on success.
    @discardableResult
    func setMyProfilePhoto(
        photo: InputProfilePhoto
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setMyProfilePhoto")
        request.set("photo", photo)
        return try await self.perform(request)
    }

    /// Removes the profile photo of the bot. Requires no parameters. Returns *True* on success.
    @discardableResult
    func removeMyProfilePhoto() async throws -> Swift.Bool {
        let request = TelegramRequest("removeMyProfilePhoto")
        return try await self.perform(request)
    }

    /// Use this method to change the default administrator rights requested by the bot when
    /// it's added as an administrator to groups or channels. These rights will be suggested to
    /// users, but they are free to modify the list before adding the bot. Returns *True* on
    /// success.
    @discardableResult
    func setMyDefaultAdministratorRights(
        rights: ChatAdministratorRights? = nil,
        forChannels: Swift.Bool? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setMyDefaultAdministratorRights")
        request.set("rights", rights)
        request.set("for_channels", forChannels)
        return try await self.perform(request)
    }

    /// Use this method to get the current default administrator rights of the bot. Returns
    /// ``ChatAdministratorRights`` on success.
    @discardableResult
    func getMyDefaultAdministratorRights(
        forChannels: Swift.Bool? = nil
    ) async throws -> ChatAdministratorRights {
        var request = TelegramRequest("getMyDefaultAdministratorRights")
        request.set("for_channels", forChannels)
        return try await self.perform(request)
    }

    /// Verifies a user [on behalf of the
    /// organization](https://telegram.org/verify#third-party-verification) which is represented
    /// by the bot. Returns *True* on success.
    @discardableResult
    func verifyUser(
        userId: Swift.Int64,
        customDescription: Swift.String? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("verifyUser")
        request.set("user_id", userId)
        request.set("custom_description", customDescription)
        return try await self.perform(request)
    }

    /// Removes verification from a user who is currently verified [on behalf of the
    /// organization](https://telegram.org/verify#third-party-verification) represented by the
    /// bot. Returns *True* on success.
    @discardableResult
    func removeUserVerification(
        userId: Swift.Int64
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("removeUserVerification")
        request.set("user_id", userId)
        return try await self.perform(request)
    }

    /// Changes the first and last name of a managed business account. Requires the
    /// *can_change_name* business bot right. Returns *True* on success.
    @discardableResult
    func setBusinessAccountName(
        businessConnectionId: Swift.String,
        firstName: Swift.String,
        lastName: Swift.String? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setBusinessAccountName")
        request.set("business_connection_id", businessConnectionId)
        request.set("first_name", firstName)
        request.set("last_name", lastName)
        return try await self.perform(request)
    }

    /// Changes the username of a managed business account. Requires the *can_change_username*
    /// business bot right. Returns *True* on success.
    @discardableResult
    func setBusinessAccountUsername(
        businessConnectionId: Swift.String,
        username: Swift.String? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setBusinessAccountUsername")
        request.set("business_connection_id", businessConnectionId)
        request.set("username", username)
        return try await self.perform(request)
    }

    /// Changes the bio of a managed business account. Requires the *can_change_bio* business
    /// bot right. Returns *True* on success.
    @discardableResult
    func setBusinessAccountBio(
        businessConnectionId: Swift.String,
        bio: Swift.String? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setBusinessAccountBio")
        request.set("business_connection_id", businessConnectionId)
        request.set("bio", bio)
        return try await self.perform(request)
    }

    /// Changes the profile photo of a managed business account. Requires the
    /// *can_edit_profile_photo* business bot right. Returns *True* on success.
    @discardableResult
    func setBusinessAccountProfilePhoto(
        businessConnectionId: Swift.String,
        photo: InputProfilePhoto,
        isPublic: Swift.Bool? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setBusinessAccountProfilePhoto")
        request.set("business_connection_id", businessConnectionId)
        request.set("photo", photo)
        request.set("is_public", isPublic)
        return try await self.perform(request)
    }

    /// Removes the current profile photo of a managed business account. Requires the
    /// *can_edit_profile_photo* business bot right. Returns *True* on success.
    @discardableResult
    func removeBusinessAccountProfilePhoto(
        businessConnectionId: Swift.String,
        isPublic: Swift.Bool? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("removeBusinessAccountProfilePhoto")
        request.set("business_connection_id", businessConnectionId)
        request.set("is_public", isPublic)
        return try await self.perform(request)
    }

    /// Stores a keyboard button that can be used by a user within a Mini App. Returns a
    /// ``PreparedKeyboardButton`` object.
    @discardableResult
    func savePreparedKeyboardButton(
        userId: Swift.Int64,
        button: KeyboardButton
    ) async throws -> PreparedKeyboardButton {
        var request = TelegramRequest("savePreparedKeyboardButton")
        request.set("user_id", userId)
        request.set("button", button)
        return try await self.perform(request)
    }

    /// Use this method to approve a suggested post in a direct messages chat. The bot must have
    /// the 'can_post_messages' administrator right in the corresponding channel chat. Returns
    /// *True* on success.
    @discardableResult
    func approveSuggestedPost(
        chatId: Swift.Int64,
        messageId: Swift.Int64,
        sendDate: Swift.Int64? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: .id(chatId))
        var request = TelegramRequest("approveSuggestedPost")
        request.set("chat_id", chatId)
        request.set("message_id", messageId)
        request.set("send_date", sendDate)
        return try await self.perform(request)
    }

    /// Use this method to decline a suggested post in a direct messages chat. The bot must have
    /// the 'can_manage_direct_messages' administrator right in the corresponding channel chat.
    /// Returns *True* on success.
    @discardableResult
    func declineSuggestedPost(
        chatId: Swift.Int64,
        messageId: Swift.Int64,
        comment: Swift.String? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: .id(chatId))
        var request = TelegramRequest("declineSuggestedPost")
        request.set("chat_id", chatId)
        request.set("message_id", messageId)
        request.set("comment", comment)
        return try await self.perform(request)
    }

    /// Informs a user that some of the Telegram Passport elements they provided contains
    /// errors. The user will not be able to re-submit their Passport to you until the errors
    /// are fixed (the contents of the field for which you returned the error must change).
    /// Returns *True* on success. Use this if the data submitted by the user doesn't satisfy
    /// the standards your service requires for any reason. For example, if a birthday date
    /// seems invalid, a submitted document is blurry, a scan shows evidence of tampering, etc.
    /// Supply some details in the error message to make sure the user knows how to correct the
    /// issues.
    @discardableResult
    func setPassportDataErrors(
        userId: Swift.Int64,
        errors: [PassportElementError]
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setPassportDataErrors")
        request.set("user_id", userId)
        request.set("errors", errors)
        return try await self.perform(request)
    }

    /// Use this method to set the score of the specified user in a game message. On success, if
    /// the message is not an inline message, the ``Message`` is returned, otherwise *True* is
    /// returned. Returns an error, if the new score is not greater than the user's current
    /// score in the chat and *force* is *False*.
    @discardableResult
    func setGameScore(
        userId: Swift.Int64,
        score: Swift.Int64,
        force: Swift.Bool? = nil,
        disableEditMessage: Swift.Bool? = nil,
        chatId: Swift.Int64? = nil,
        messageId: Swift.Int64? = nil,
        inlineMessageId: Swift.String? = nil
    ) async throws -> Message? {
        try await self.pace(chatId: chatId.map(ChatId.id))
        var request = TelegramRequest("setGameScore")
        request.set("user_id", userId)
        request.set("score", score)
        request.set("force", force)
        request.set("disable_edit_message", disableEditMessage)
        request.set("chat_id", chatId)
        request.set("message_id", messageId)
        request.set("inline_message_id", inlineMessageId)
        return try await self.performMessageOrFlag(request)
    }

    /// Use this method to get data for high score tables. Will return the score of the
    /// specified user and several of their neighbors in a game. Returns an Array of
    /// ``GameHighScore`` objects. This method will currently return scores for the target user,
    /// plus two of their closest neighbors on each side. Will also return the top three users
    /// if the user and their neighbors are not among them. Please note that this behavior is
    /// subject to change.
    @discardableResult
    func getGameHighScores(
        userId: Swift.Int64,
        chatId: Swift.Int64? = nil,
        messageId: Swift.Int64? = nil,
        inlineMessageId: Swift.String? = nil
    ) async throws -> [GameHighScore] {
        try await self.pace(chatId: chatId.map(ChatId.id))
        var request = TelegramRequest("getGameHighScores")
        request.set("user_id", userId)
        request.set("chat_id", chatId)
        request.set("message_id", messageId)
        request.set("inline_message_id", inlineMessageId)
        return try await self.perform(request)
    }
}
