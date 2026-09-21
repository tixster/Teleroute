// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

import Foundation
import TelegramBotAPI

public extension TelegramBotClient {
    /// Use this method to set a new group sticker set for a supergroup. The bot must be an
    /// administrator in the chat for this to work and must have the appropriate administrator
    /// rights. Use the field *can_set_sticker_set* optionally returned in `getChat` requests to
    /// check if the bot can use this method. Returns *True* on success.
    @discardableResult
    func setChatStickerSet(
        chatId: ChatId,
        stickerSetName: Swift.String
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("setChatStickerSet")
        request.set("chat_id", chatId)
        request.set("sticker_set_name", stickerSetName)
        return try await self.perform(request)
    }

    /// Use this method to delete a group sticker set from a supergroup. The bot must be an
    /// administrator in the chat for this to work and must have the appropriate administrator
    /// rights. Use the field *can_set_sticker_set* optionally returned in `getChat` requests to
    /// check if the bot can use this method. Returns *True* on success.
    @discardableResult
    func deleteChatStickerSet(
        chatId: ChatId
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("deleteChatStickerSet")
        request.set("chat_id", chatId)
        return try await self.perform(request)
    }

    /// Use this method to get custom emoji stickers, which can be used as a forum topic icon by
    /// any user. Requires no parameters. Returns an Array of ``Sticker`` objects.
    @discardableResult
    func getForumTopicIconStickers() async throws -> [Sticker] {
        let request = TelegramRequest("getForumTopicIconStickers")
        return try await self.perform(request)
    }

    /// Use this method to send static .WEBP,
    /// [animated](https://telegram.org/blog/animated-stickers) .TGS, or
    /// [video](https://telegram.org/blog/video-stickers-better-reactions) .WEBM stickers. On
    /// success, the sent ``Message`` is returned.
    @discardableResult
    func sendSticker(
        chatId: ChatId,
        sticker: FileInput,
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        ephemeralMessageParameters: EphemeralMessageParameters? = nil,
        emoji: Swift.String? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        suggestedPostParameters: SuggestedPostParameters? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendSticker")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("ephemeral_message_parameters", ephemeralMessageParameters)
        request.set("sticker", sticker)
        request.set("emoji", emoji)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("suggested_post_parameters", suggestedPostParameters)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to get a sticker set. On success, a ``StickerSet`` object is returned.
    @discardableResult
    func getStickerSet(
        name: Swift.String
    ) async throws -> StickerSet {
        var request = TelegramRequest("getStickerSet")
        request.set("name", name)
        return try await self.perform(request)
    }

    /// Use this method to get information about custom emoji stickers by their identifiers.
    /// Returns an Array of ``Sticker`` objects.
    @discardableResult
    func getCustomEmojiStickers(
        customEmojiIds: [Swift.String]
    ) async throws -> [Sticker] {
        var request = TelegramRequest("getCustomEmojiStickers")
        request.set("custom_emoji_ids", customEmojiIds)
        return try await self.perform(request)
    }

    /// Use this method to upload a file with a sticker for later use in the
    /// `createNewStickerSet`, `addStickerToSet`, or `replaceStickerInSet` methods (the file can
    /// be used multiple times). Returns the uploaded ``File`` on success.
    @discardableResult
    func uploadStickerFile(
        userId: Swift.Int64,
        sticker: FileInput,
        stickerFormat: InputStickerFormat
    ) async throws -> File {
        var request = TelegramRequest("uploadStickerFile")
        request.set("user_id", userId)
        request.set("sticker", sticker)
        request.set("sticker_format", stickerFormat)
        return try await self.perform(request)
    }

    /// Use this method to create a new sticker set owned by a user. The bot will be able to
    /// edit the sticker set thus created. Returns *True* on success.
    @discardableResult
    func createNewStickerSet(
        userId: Swift.Int64,
        name: Swift.String,
        title: Swift.String,
        stickers: [InputSticker],
        stickerType: Swift.String? = nil,
        needsRepainting: Swift.Bool? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("createNewStickerSet")
        request.set("user_id", userId)
        request.set("name", name)
        request.set("title", title)
        request.set("stickers", stickers)
        request.set("sticker_type", stickerType)
        request.set("needs_repainting", needsRepainting)
        return try await self.perform(request)
    }

    /// Use this method to add a new sticker to a set created by the bot. Emoji sticker sets can
    /// have up to 200 stickers. Other sticker sets can have up to 120 stickers. Returns *True*
    /// on success.
    @discardableResult
    func addStickerToSet(
        userId: Swift.Int64,
        name: Swift.String,
        sticker: InputSticker
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("addStickerToSet")
        request.set("user_id", userId)
        request.set("name", name)
        request.set("sticker", sticker)
        return try await self.perform(request)
    }

    /// Use this method to move a sticker in a set created by the bot to a specific position.
    /// Returns *True* on success.
    @discardableResult
    func setStickerPositionInSet(
        sticker: Swift.String,
        position: Swift.Int64
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setStickerPositionInSet")
        request.set("sticker", sticker)
        request.set("position", position)
        return try await self.perform(request)
    }

    /// Use this method to delete a sticker from a set created by the bot. Returns *True* on
    /// success.
    @discardableResult
    func deleteStickerFromSet(
        sticker: Swift.String
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("deleteStickerFromSet")
        request.set("sticker", sticker)
        return try await self.perform(request)
    }

    /// Use this method to replace an existing sticker in a sticker set with a new one. The
    /// method is equivalent to calling `deleteStickerFromSet`, then `addStickerToSet`, then
    /// `setStickerPositionInSet`. Returns *True* on success.
    @discardableResult
    func replaceStickerInSet(
        userId: Swift.Int64,
        name: Swift.String,
        oldSticker: Swift.String,
        sticker: InputSticker
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("replaceStickerInSet")
        request.set("user_id", userId)
        request.set("name", name)
        request.set("old_sticker", oldSticker)
        request.set("sticker", sticker)
        return try await self.perform(request)
    }

    /// Use this method to change the list of emoji assigned to a regular or custom emoji
    /// sticker. The sticker must belong to a sticker set created by the bot. Returns *True* on
    /// success.
    @discardableResult
    func setStickerEmojiList(
        sticker: Swift.String,
        emojiList: [Swift.String]
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setStickerEmojiList")
        request.set("sticker", sticker)
        request.set("emoji_list", emojiList)
        return try await self.perform(request)
    }

    /// Use this method to change search keywords assigned to a regular or custom emoji sticker.
    /// The sticker must belong to a sticker set created by the bot. Returns *True* on success.
    @discardableResult
    func setStickerKeywords(
        sticker: Swift.String,
        keywords: [Swift.String]? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setStickerKeywords")
        request.set("sticker", sticker)
        request.set("keywords", keywords)
        return try await self.perform(request)
    }

    /// Use this method to change the mask position of a mask sticker. The sticker must belong
    /// to a sticker set that was created by the bot. Returns *True* on success.
    @discardableResult
    func setStickerMaskPosition(
        sticker: Swift.String,
        maskPosition: MaskPosition? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setStickerMaskPosition")
        request.set("sticker", sticker)
        request.set("mask_position", maskPosition)
        return try await self.perform(request)
    }

    /// Use this method to set the title of a created sticker set. Returns *True* on success.
    @discardableResult
    func setStickerSetTitle(
        name: Swift.String,
        title: Swift.String
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setStickerSetTitle")
        request.set("name", name)
        request.set("title", title)
        return try await self.perform(request)
    }

    /// Use this method to set the thumbnail of a regular or mask sticker set. The format of the
    /// thumbnail file must match the format of the stickers in the set. Returns *True* on
    /// success.
    @discardableResult
    func setStickerSetThumbnail(
        name: Swift.String,
        userId: Swift.Int64,
        format: InputStickerFormat,
        thumbnail: FileInput? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setStickerSetThumbnail")
        request.set("name", name)
        request.set("user_id", userId)
        request.set("thumbnail", thumbnail)
        request.set("format", format)
        return try await self.perform(request)
    }

    /// Use this method to set the thumbnail of a custom emoji sticker set. Returns *True* on
    /// success.
    @discardableResult
    func setCustomEmojiStickerSetThumbnail(
        name: Swift.String,
        customEmojiId: Swift.String? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setCustomEmojiStickerSetThumbnail")
        request.set("name", name)
        request.set("custom_emoji_id", customEmojiId)
        return try await self.perform(request)
    }

    /// Use this method to delete a sticker set that was created by the bot. Returns *True* on
    /// success.
    @discardableResult
    func deleteStickerSet(
        name: Swift.String
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("deleteStickerSet")
        request.set("name", name)
        return try await self.perform(request)
    }
}
