// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

import Foundation
import TelegramBotAPI

public extension TelegramBotClient {
    /// Use this method to send text messages. On success, the sent ``Message`` is returned.
    @discardableResult
    func sendMessage(
        chatId: ChatId,
        text: Swift.String,
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        ephemeralMessageParameters: EphemeralMessageParameters? = nil,
        parseMode: ParseMode? = nil,
        entities: [MessageEntity]? = nil,
        linkPreviewOptions: LinkPreviewOptions? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        suggestedPostParameters: SuggestedPostParameters? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendMessage")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("ephemeral_message_parameters", ephemeralMessageParameters)
        request.set("text", text)
        request.set("parse_mode", parseMode?.rawValue)
        request.set("entities", entities)
        request.set("link_preview_options", linkPreviewOptions)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("suggested_post_parameters", suggestedPostParameters)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to forward messages of any kind. Service messages and messages with
    /// protected content can't be forwarded. On success, the sent ``Message`` is returned.
    @discardableResult
    func forwardMessage(
        chatId: ChatId,
        fromChatId: ChatId,
        messageId: Swift.Int64,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        videoStartTimestamp: Swift.Int64? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        suggestedPostParameters: SuggestedPostParameters? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("forwardMessage")
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("from_chat_id", fromChatId)
        request.set("video_start_timestamp", videoStartTimestamp)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("message_effect_id", messageEffectId)
        request.set("suggested_post_parameters", suggestedPostParameters)
        request.set("message_id", messageId)
        return try await self.perform(request)
    }

    /// Use this method to forward multiple messages of any kind. If some of the specified
    /// messages can't be found or forwarded, they are skipped. Service messages and messages
    /// with protected content can't be forwarded. Album grouping is kept for forwarded
    /// messages. On success, an Array of ``MessageId`` of the sent messages is returned.
    @discardableResult
    func forwardMessages(
        chatId: ChatId,
        fromChatId: ChatId,
        messageIds: [Swift.Int64],
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil
    ) async throws -> [MessageId] {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("forwardMessages")
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("from_chat_id", fromChatId)
        request.set("message_ids", messageIds)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        return try await self.perform(request)
    }

    /// Use this method to copy messages of any kind. Service messages, paid media messages,
    /// giveaway messages, giveaway winners messages, and invoice messages can't be copied. A
    /// quiz `poll` can be copied only if the value of the field *correct_option_ids* is known
    /// to the bot. The method is analogous to the method `forwardMessage`, but the copied
    /// message doesn't have a link to the original message. Returns the ``MessageId`` of the
    /// sent message on success.
    @discardableResult
    func copyMessage(
        chatId: ChatId,
        fromChatId: ChatId,
        messageId: Swift.Int64,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        videoStartTimestamp: Swift.Int64? = nil,
        caption: Swift.String? = nil,
        parseMode: ParseMode? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Swift.Bool? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        suggestedPostParameters: SuggestedPostParameters? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> MessageId {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("copyMessage")
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("from_chat_id", fromChatId)
        request.set("message_id", messageId)
        request.set("video_start_timestamp", videoStartTimestamp)
        request.set("caption", caption)
        request.set("parse_mode", parseMode?.rawValue)
        request.set("caption_entities", captionEntities)
        request.set("show_caption_above_media", showCaptionAboveMedia)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("suggested_post_parameters", suggestedPostParameters)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to copy messages of any kind. If some of the specified messages can't be
    /// found or copied, they are skipped. Service messages, paid media messages, giveaway
    /// messages, giveaway winners messages, and invoice messages can't be copied. A quiz `poll`
    /// can be copied only if the value of the field *correct_option_ids* is known to the bot.
    /// The method is analogous to the method `forwardMessages`, but the copied messages don't
    /// have a link to the original message. Album grouping is kept for copied messages. On
    /// success, an Array of ``MessageId`` of the sent messages is returned.
    @discardableResult
    func copyMessages(
        chatId: ChatId,
        fromChatId: ChatId,
        messageIds: [Swift.Int64],
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        removeCaption: Swift.Bool? = nil
    ) async throws -> [MessageId] {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("copyMessages")
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("from_chat_id", fromChatId)
        request.set("message_ids", messageIds)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("remove_caption", removeCaption)
        return try await self.perform(request)
    }

    /// Use this method to send photos. On success, the sent ``Message`` is returned.
    @discardableResult
    func sendPhoto(
        chatId: ChatId,
        photo: FileInput,
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        ephemeralMessageParameters: EphemeralMessageParameters? = nil,
        caption: Swift.String? = nil,
        parseMode: ParseMode? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Swift.Bool? = nil,
        hasSpoiler: Swift.Bool? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        suggestedPostParameters: SuggestedPostParameters? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendPhoto")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("ephemeral_message_parameters", ephemeralMessageParameters)
        request.set("photo", photo)
        request.set("caption", caption)
        request.set("parse_mode", parseMode?.rawValue)
        request.set("caption_entities", captionEntities)
        request.set("show_caption_above_media", showCaptionAboveMedia)
        request.set("has_spoiler", hasSpoiler)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("suggested_post_parameters", suggestedPostParameters)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to send live photos. On success, the sent ``Message`` is returned.
    @discardableResult
    func sendLivePhoto(
        chatId: ChatId,
        livePhoto: FileInput,
        photo: FileInput,
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        ephemeralMessageParameters: EphemeralMessageParameters? = nil,
        caption: Swift.String? = nil,
        parseMode: ParseMode? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Swift.Bool? = nil,
        hasSpoiler: Swift.Bool? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        suggestedPostParameters: SuggestedPostParameters? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendLivePhoto")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("ephemeral_message_parameters", ephemeralMessageParameters)
        request.set("live_photo", livePhoto)
        request.set("photo", photo)
        request.set("caption", caption)
        request.set("parse_mode", parseMode?.rawValue)
        request.set("caption_entities", captionEntities)
        request.set("show_caption_above_media", showCaptionAboveMedia)
        request.set("has_spoiler", hasSpoiler)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("suggested_post_parameters", suggestedPostParameters)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to send audio files, if you want Telegram clients to display them in the
    /// music player. Your audio must be in the .MP3 or .M4A format. On success, the sent
    /// ``Message`` is returned. Bots can currently send audio files of up to 50 MB in size,
    /// this limit may be changed in the future. For sending voice messages, use the `sendVoice`
    /// method instead.
    @discardableResult
    func sendAudio(
        chatId: ChatId,
        audio: FileInput,
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        ephemeralMessageParameters: EphemeralMessageParameters? = nil,
        caption: Swift.String? = nil,
        parseMode: ParseMode? = nil,
        captionEntities: [MessageEntity]? = nil,
        duration: Swift.Int64? = nil,
        performer: Swift.String? = nil,
        title: Swift.String? = nil,
        thumbnail: FileInput? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        suggestedPostParameters: SuggestedPostParameters? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendAudio")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("ephemeral_message_parameters", ephemeralMessageParameters)
        request.set("audio", audio)
        request.set("caption", caption)
        request.set("parse_mode", parseMode?.rawValue)
        request.set("caption_entities", captionEntities)
        request.set("duration", duration)
        request.set("performer", performer)
        request.set("title", title)
        request.set("thumbnail", thumbnail)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("suggested_post_parameters", suggestedPostParameters)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to send general files. On success, the sent ``Message`` is returned.
    /// Bots can currently send files of any type of up to 50 MB in size, this limit may be
    /// changed in the future.
    @discardableResult
    func sendDocument(
        chatId: ChatId,
        document: FileInput,
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        ephemeralMessageParameters: EphemeralMessageParameters? = nil,
        thumbnail: FileInput? = nil,
        caption: Swift.String? = nil,
        parseMode: ParseMode? = nil,
        captionEntities: [MessageEntity]? = nil,
        disableContentTypeDetection: Swift.Bool? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        suggestedPostParameters: SuggestedPostParameters? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendDocument")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("ephemeral_message_parameters", ephemeralMessageParameters)
        request.set("document", document)
        request.set("thumbnail", thumbnail)
        request.set("caption", caption)
        request.set("parse_mode", parseMode?.rawValue)
        request.set("caption_entities", captionEntities)
        request.set("disable_content_type_detection", disableContentTypeDetection)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("suggested_post_parameters", suggestedPostParameters)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to send video files, Telegram clients support MPEG4 videos (other
    /// formats may be sent as ``Document``). On success, the sent ``Message`` is returned. Bots
    /// can currently send video files of up to 50 MB in size, this limit may be changed in the
    /// future.
    @discardableResult
    func sendVideo(
        chatId: ChatId,
        video: FileInput,
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        ephemeralMessageParameters: EphemeralMessageParameters? = nil,
        duration: Swift.Int64? = nil,
        width: Swift.Int64? = nil,
        height: Swift.Int64? = nil,
        thumbnail: FileInput? = nil,
        cover: FileInput? = nil,
        startTimestamp: Swift.Int64? = nil,
        caption: Swift.String? = nil,
        parseMode: ParseMode? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Swift.Bool? = nil,
        hasSpoiler: Swift.Bool? = nil,
        supportsStreaming: Swift.Bool? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        suggestedPostParameters: SuggestedPostParameters? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendVideo")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("ephemeral_message_parameters", ephemeralMessageParameters)
        request.set("video", video)
        request.set("duration", duration)
        request.set("width", width)
        request.set("height", height)
        request.set("thumbnail", thumbnail)
        request.set("cover", cover)
        request.set("start_timestamp", startTimestamp)
        request.set("caption", caption)
        request.set("parse_mode", parseMode?.rawValue)
        request.set("caption_entities", captionEntities)
        request.set("show_caption_above_media", showCaptionAboveMedia)
        request.set("has_spoiler", hasSpoiler)
        request.set("supports_streaming", supportsStreaming)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("suggested_post_parameters", suggestedPostParameters)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to send animation files (GIF or H.264/MPEG-4 AVC video without sound).
    /// On success, the sent ``Message`` is returned. Bots can currently send animation files of
    /// up to 50 MB in size, this limit may be changed in the future.
    @discardableResult
    func sendAnimation(
        chatId: ChatId,
        animation: FileInput,
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        ephemeralMessageParameters: EphemeralMessageParameters? = nil,
        duration: Swift.Int64? = nil,
        width: Swift.Int64? = nil,
        height: Swift.Int64? = nil,
        thumbnail: FileInput? = nil,
        caption: Swift.String? = nil,
        parseMode: ParseMode? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Swift.Bool? = nil,
        hasSpoiler: Swift.Bool? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        suggestedPostParameters: SuggestedPostParameters? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendAnimation")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("ephemeral_message_parameters", ephemeralMessageParameters)
        request.set("animation", animation)
        request.set("duration", duration)
        request.set("width", width)
        request.set("height", height)
        request.set("thumbnail", thumbnail)
        request.set("caption", caption)
        request.set("parse_mode", parseMode?.rawValue)
        request.set("caption_entities", captionEntities)
        request.set("show_caption_above_media", showCaptionAboveMedia)
        request.set("has_spoiler", hasSpoiler)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("suggested_post_parameters", suggestedPostParameters)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to send audio files, if you want Telegram clients to display the file as
    /// a playable voice message. For this to work, your audio must be in an .OGG file encoded
    /// with OPUS, or in .MP3 format, or in .M4A format (other formats may be sent as ``Audio``
    /// or ``Document``). On success, the sent ``Message`` is returned. Bots can currently send
    /// voice messages of up to 50 MB in size, this limit may be changed in the future.
    @discardableResult
    func sendVoice(
        chatId: ChatId,
        voice: FileInput,
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        ephemeralMessageParameters: EphemeralMessageParameters? = nil,
        caption: Swift.String? = nil,
        parseMode: ParseMode? = nil,
        captionEntities: [MessageEntity]? = nil,
        duration: Swift.Int64? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        suggestedPostParameters: SuggestedPostParameters? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendVoice")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("ephemeral_message_parameters", ephemeralMessageParameters)
        request.set("voice", voice)
        request.set("caption", caption)
        request.set("parse_mode", parseMode?.rawValue)
        request.set("caption_entities", captionEntities)
        request.set("duration", duration)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("suggested_post_parameters", suggestedPostParameters)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to send a rounded square MPEG4 video of up to 1 minute long. On success,
    /// the sent ``Message`` is returned.
    @discardableResult
    func sendVideoNote(
        chatId: ChatId,
        videoNote: FileInput,
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        ephemeralMessageParameters: EphemeralMessageParameters? = nil,
        duration: Swift.Int64? = nil,
        length: Swift.Int64? = nil,
        thumbnail: FileInput? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        suggestedPostParameters: SuggestedPostParameters? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendVideoNote")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("ephemeral_message_parameters", ephemeralMessageParameters)
        request.set("video_note", videoNote)
        request.set("duration", duration)
        request.set("length", length)
        request.set("thumbnail", thumbnail)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("suggested_post_parameters", suggestedPostParameters)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to send a group of photos, live photos, videos, documents or audios as
    /// an album. Documents and audio files can be only grouped in an album with messages of the
    /// same type. On success, an Array of ``Message`` objects that were sent is returned.
    @discardableResult
    func sendMediaGroup(
        chatId: ChatId,
        media: [MediaGroupInputMedia],
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        replyParameters: ReplyParameters? = nil
    ) async throws -> [Message] {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendMediaGroup")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("media", media)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("reply_parameters", replyParameters)
        return try await self.perform(request)
    }

    /// Use this method to send point on the map. On success, the sent ``Message`` is returned.
    @discardableResult
    func sendLocation(
        chatId: ChatId,
        latitude: Swift.Double,
        longitude: Swift.Double,
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        ephemeralMessageParameters: EphemeralMessageParameters? = nil,
        horizontalAccuracy: Swift.Double? = nil,
        livePeriod: Swift.Int64? = nil,
        heading: Swift.Int64? = nil,
        proximityAlertRadius: Swift.Int64? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        suggestedPostParameters: SuggestedPostParameters? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendLocation")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("ephemeral_message_parameters", ephemeralMessageParameters)
        request.set("latitude", latitude)
        request.set("longitude", longitude)
        request.set("horizontal_accuracy", horizontalAccuracy)
        request.set("live_period", livePeriod)
        request.set("heading", heading)
        request.set("proximity_alert_radius", proximityAlertRadius)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("suggested_post_parameters", suggestedPostParameters)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to send information about a venue. On success, the sent ``Message`` is
    /// returned.
    @discardableResult
    func sendVenue(
        chatId: ChatId,
        latitude: Swift.Double,
        longitude: Swift.Double,
        title: Swift.String,
        address: Swift.String,
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        ephemeralMessageParameters: EphemeralMessageParameters? = nil,
        foursquareId: Swift.String? = nil,
        foursquareType: Swift.String? = nil,
        googlePlaceId: Swift.String? = nil,
        googlePlaceType: Swift.String? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        suggestedPostParameters: SuggestedPostParameters? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendVenue")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("ephemeral_message_parameters", ephemeralMessageParameters)
        request.set("latitude", latitude)
        request.set("longitude", longitude)
        request.set("title", title)
        request.set("address", address)
        request.set("foursquare_id", foursquareId)
        request.set("foursquare_type", foursquareType)
        request.set("google_place_id", googlePlaceId)
        request.set("google_place_type", googlePlaceType)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("suggested_post_parameters", suggestedPostParameters)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to send phone contacts. On success, the sent ``Message`` is returned.
    @discardableResult
    func sendContact(
        chatId: ChatId,
        phoneNumber: Swift.String,
        firstName: Swift.String,
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        ephemeralMessageParameters: EphemeralMessageParameters? = nil,
        lastName: Swift.String? = nil,
        vcard: Swift.String? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        suggestedPostParameters: SuggestedPostParameters? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendContact")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("ephemeral_message_parameters", ephemeralMessageParameters)
        request.set("phone_number", phoneNumber)
        request.set("first_name", firstName)
        request.set("last_name", lastName)
        request.set("vcard", vcard)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("suggested_post_parameters", suggestedPostParameters)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to send a native poll. On success, the sent ``Message`` is returned.
    @discardableResult
    func sendPoll(
        chatId: ChatId,
        question: Swift.String,
        options: [InputPollOption],
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        questionParseMode: Swift.String? = nil,
        questionEntities: [MessageEntity]? = nil,
        isAnonymous: Swift.Bool? = nil,
        type: Swift.String? = nil,
        allowsMultipleAnswers: Swift.Bool? = nil,
        allowsRevoting: Swift.Bool? = nil,
        shuffleOptions: Swift.Bool? = nil,
        allowAddingOptions: Swift.Bool? = nil,
        hideResultsUntilCloses: Swift.Bool? = nil,
        membersOnly: Swift.Bool? = nil,
        countryCodes: [Swift.String]? = nil,
        correctOptionIds: [Swift.Int64]? = nil,
        explanation: Swift.String? = nil,
        explanationParseMode: Swift.String? = nil,
        explanationEntities: [MessageEntity]? = nil,
        explanationMedia: InputPollMedia? = nil,
        openPeriod: Swift.Int64? = nil,
        closeDate: Swift.Int64? = nil,
        isClosed: Swift.Bool? = nil,
        description: Swift.String? = nil,
        descriptionParseMode: Swift.String? = nil,
        descriptionEntities: [MessageEntity]? = nil,
        media: InputPollMedia? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendPoll")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("question", question)
        request.set("question_parse_mode", questionParseMode)
        request.set("question_entities", questionEntities)
        request.set("options", options)
        request.set("is_anonymous", isAnonymous)
        request.set("type", type)
        request.set("allows_multiple_answers", allowsMultipleAnswers)
        request.set("allows_revoting", allowsRevoting)
        request.set("shuffle_options", shuffleOptions)
        request.set("allow_adding_options", allowAddingOptions)
        request.set("hide_results_until_closes", hideResultsUntilCloses)
        request.set("members_only", membersOnly)
        request.set("country_codes", countryCodes)
        request.set("correct_option_ids", correctOptionIds)
        request.set("explanation", explanation)
        request.set("explanation_parse_mode", explanationParseMode)
        request.set("explanation_entities", explanationEntities)
        request.set("explanation_media", explanationMedia)
        request.set("open_period", openPeriod)
        request.set("close_date", closeDate)
        request.set("is_closed", isClosed)
        request.set("description", description)
        request.set("description_parse_mode", descriptionParseMode)
        request.set("description_entities", descriptionEntities)
        request.set("media", media)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to send a checklist on behalf of a connected business account. On
    /// success, the sent ``Message`` is returned.
    @discardableResult
    func sendChecklist(
        businessConnectionId: Swift.String,
        chatId: ChatId,
        checklist: InputChecklist,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendChecklist")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("checklist", checklist)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("message_effect_id", messageEffectId)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to send an animated emoji that will display a random value. On success,
    /// the sent ``Message`` is returned.
    @discardableResult
    func sendDice(
        chatId: ChatId,
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
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
        var request = TelegramRequest("sendDice")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
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

    /// Use this method to stream a partial message to a user while the message is being
    /// generated. Note that the streamed draft is ephemeral and acts as a temporary 30-second
    /// preview - once the output is finalized, you **must** call `sendMessage` with the
    /// complete message to persist it in the user's chat. Returns *True* on success.
    @discardableResult
    func sendMessageDraft(
        chatId: Swift.Int64,
        draftId: Swift.Int64,
        messageThreadId: Swift.Int64? = nil,
        text: Swift.String? = nil,
        parseMode: ParseMode? = nil,
        entities: [MessageEntity]? = nil,
        canStop: Swift.Bool? = nil,
        keepOnStop: Swift.Bool? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: .id(chatId))
        var request = TelegramRequest("sendMessageDraft")
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("draft_id", draftId)
        request.set("text", text)
        request.set("parse_mode", parseMode?.rawValue)
        request.set("entities", entities)
        request.set("can_stop", canStop)
        request.set("keep_on_stop", keepOnStop)
        return try await self.perform(request)
    }

    /// Use this method to change the chosen reactions on a message. Service messages of some
    /// types can't be reacted to. Automatically forwarded messages from a channel to its
    /// discussion group have the same available reactions as messages in the channel. Bots
    /// can't use paid reactions. Returns *True* on success.
    @discardableResult
    func setMessageReaction(
        chatId: ChatId,
        messageId: Swift.Int64,
        reaction: [ReactionType]? = nil,
        isBig: Swift.Bool? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("setMessageReaction")
        request.set("chat_id", chatId)
        request.set("message_id", messageId)
        request.set("reaction", reaction)
        request.set("is_big", isBig)
        return try await self.perform(request)
    }

    /// Use this method to delete the list of the bot's commands for the given scope and user
    /// language. After deletion, higher level commands will be shown to affected users. Returns
    /// *True* on success.
    @discardableResult
    func deleteMyCommands(
        scope: BotCommandScope? = nil,
        languageCode: Swift.String? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("deleteMyCommands")
        request.set("scope", scope)
        request.set("language_code", languageCode)
        return try await self.perform(request)
    }

    /// Marks incoming message as read on behalf of a business account. Requires the
    /// *can_read_messages* business bot right. Returns *True* on success.
    @discardableResult
    func readBusinessMessage(
        businessConnectionId: Swift.String,
        chatId: Swift.Int64,
        messageId: Swift.Int64
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: .id(chatId))
        var request = TelegramRequest("readBusinessMessage")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_id", messageId)
        return try await self.perform(request)
    }

    /// Delete messages on behalf of a business account. Requires the *can_delete_sent_messages*
    /// business bot right to delete messages sent by the bot itself, or the
    /// *can_delete_all_messages* business bot right to delete any message. Returns *True* on
    /// success.
    @discardableResult
    func deleteBusinessMessages(
        businessConnectionId: Swift.String,
        messageIds: [Swift.Int64]
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("deleteBusinessMessages")
        request.set("business_connection_id", businessConnectionId)
        request.set("message_ids", messageIds)
        return try await self.perform(request)
    }

    /// Posts a story on behalf of a managed business account. Requires the *can_manage_stories*
    /// business bot right. Returns ``Story`` on success.
    @discardableResult
    func postStory(
        businessConnectionId: Swift.String,
        content: InputStoryContent,
        activePeriod: Swift.Int64,
        caption: Swift.String? = nil,
        parseMode: ParseMode? = nil,
        captionEntities: [MessageEntity]? = nil,
        areas: [StoryArea]? = nil,
        postToChatPage: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil
    ) async throws -> Story {
        var request = TelegramRequest("postStory")
        request.set("business_connection_id", businessConnectionId)
        request.set("content", content)
        request.set("active_period", activePeriod)
        request.set("caption", caption)
        request.set("parse_mode", parseMode?.rawValue)
        request.set("caption_entities", captionEntities)
        request.set("areas", areas)
        request.set("post_to_chat_page", postToChatPage)
        request.set("protect_content", protectContent)
        return try await self.perform(request)
    }

    /// Reposts a story on behalf of a business account from another business account. Both
    /// business accounts must be managed by the same bot, and the story on the source account
    /// must have been posted (or reposted) by the bot. Requires the *can_manage_stories*
    /// business bot right for both business accounts. Returns ``Story`` on success.
    @discardableResult
    func repostStory(
        businessConnectionId: Swift.String,
        fromChatId: Swift.Int64,
        fromStoryId: Swift.Int64,
        activePeriod: Swift.Int64,
        postToChatPage: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil
    ) async throws -> Story {
        var request = TelegramRequest("repostStory")
        request.set("business_connection_id", businessConnectionId)
        request.set("from_chat_id", fromChatId)
        request.set("from_story_id", fromStoryId)
        request.set("active_period", activePeriod)
        request.set("post_to_chat_page", postToChatPage)
        request.set("protect_content", protectContent)
        return try await self.perform(request)
    }

    /// Edits a story previously posted by the bot on behalf of a managed business account.
    /// Requires the *can_manage_stories* business bot right. Returns ``Story`` on success.
    @discardableResult
    func editStory(
        businessConnectionId: Swift.String,
        storyId: Swift.Int64,
        content: InputStoryContent,
        caption: Swift.String? = nil,
        parseMode: ParseMode? = nil,
        captionEntities: [MessageEntity]? = nil,
        areas: [StoryArea]? = nil
    ) async throws -> Story {
        var request = TelegramRequest("editStory")
        request.set("business_connection_id", businessConnectionId)
        request.set("story_id", storyId)
        request.set("content", content)
        request.set("caption", caption)
        request.set("parse_mode", parseMode?.rawValue)
        request.set("caption_entities", captionEntities)
        request.set("areas", areas)
        return try await self.perform(request)
    }

    /// Deletes a story previously posted by the bot on behalf of a managed business account.
    /// Requires the *can_manage_stories* business bot right. Returns *True* on success.
    @discardableResult
    func deleteStory(
        businessConnectionId: Swift.String,
        storyId: Swift.Int64
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("deleteStory")
        request.set("business_connection_id", businessConnectionId)
        request.set("story_id", storyId)
        return try await self.perform(request)
    }

    /// Use this method to edit text, rich and `game` messages. On success, if the edited
    /// message is not an inline message, the edited ``Message`` is returned, otherwise *True*
    /// is returned. Note that business messages that were not sent by the bot and do not
    /// contain an inline keyboard can only be edited within **48 hours** from the time they
    /// were sent.
    @discardableResult
    func editMessageText(
        businessConnectionId: Swift.String? = nil,
        chatId: ChatId? = nil,
        messageId: Swift.Int64? = nil,
        inlineMessageId: Swift.String? = nil,
        text: Swift.String? = nil,
        parseMode: ParseMode? = nil,
        entities: [MessageEntity]? = nil,
        linkPreviewOptions: LinkPreviewOptions? = nil,
        richMessage: InputRichMessage? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) async throws -> Message? {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("editMessageText")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_id", messageId)
        request.set("inline_message_id", inlineMessageId)
        request.set("text", text)
        request.set("parse_mode", parseMode?.rawValue)
        request.set("entities", entities)
        request.set("link_preview_options", linkPreviewOptions)
        request.set("rich_message", richMessage)
        request.set("reply_markup", replyMarkup)
        return try await self.performMessageOrFlag(request)
    }

    /// Use this method to edit captions of messages. On success, if the edited message is not
    /// an inline message, the edited ``Message`` is returned, otherwise *True* is returned.
    /// Note that business messages that were not sent by the bot and do not contain an inline
    /// keyboard can only be edited within **48 hours** from the time they were sent.
    @discardableResult
    func editMessageCaption(
        businessConnectionId: Swift.String? = nil,
        chatId: ChatId? = nil,
        messageId: Swift.Int64? = nil,
        inlineMessageId: Swift.String? = nil,
        caption: Swift.String? = nil,
        parseMode: ParseMode? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Swift.Bool? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) async throws -> Message? {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("editMessageCaption")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_id", messageId)
        request.set("inline_message_id", inlineMessageId)
        request.set("caption", caption)
        request.set("parse_mode", parseMode?.rawValue)
        request.set("caption_entities", captionEntities)
        request.set("show_caption_above_media", showCaptionAboveMedia)
        request.set("reply_markup", replyMarkup)
        return try await self.performMessageOrFlag(request)
    }

    /// Use this method to edit animation, audio, document, live photo, photo, or video
    /// messages, or to replace a text or a rich message with a media. If a message is part of a
    /// message album, then it can be edited only to an audio for audio albums, only to a
    /// document for document albums and to a photo, a live photo, or a video otherwise. When an
    /// inline message is edited, a new file can't be uploaded; use a previously uploaded file
    /// via its file_id or specify a URL. On success, if the edited message is not an inline
    /// message, the edited ``Message`` is returned, otherwise *True* is returned. Note that
    /// business messages that were not sent by the bot and do not contain an inline keyboard
    /// can only be edited within **48 hours** from the time they were sent.
    @discardableResult
    func editMessageMedia(
        media: InputMedia,
        businessConnectionId: Swift.String? = nil,
        chatId: ChatId? = nil,
        messageId: Swift.Int64? = nil,
        inlineMessageId: Swift.String? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) async throws -> Message? {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("editMessageMedia")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_id", messageId)
        request.set("inline_message_id", inlineMessageId)
        request.set("media", media)
        request.set("reply_markup", replyMarkup)
        return try await self.performMessageOrFlag(request)
    }

    /// Use this method to edit live location messages. A location can be edited until its
    /// *live_period* expires or editing is explicitly disabled by a call to
    /// `stopMessageLiveLocation`. On success, if the edited message is not an inline message,
    /// the edited ``Message`` is returned, otherwise *True* is returned.
    @discardableResult
    func editMessageLiveLocation(
        latitude: Swift.Double,
        longitude: Swift.Double,
        businessConnectionId: Swift.String? = nil,
        chatId: ChatId? = nil,
        messageId: Swift.Int64? = nil,
        inlineMessageId: Swift.String? = nil,
        livePeriod: Swift.Int64? = nil,
        horizontalAccuracy: Swift.Double? = nil,
        heading: Swift.Int64? = nil,
        proximityAlertRadius: Swift.Int64? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) async throws -> Message? {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("editMessageLiveLocation")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_id", messageId)
        request.set("inline_message_id", inlineMessageId)
        request.set("latitude", latitude)
        request.set("longitude", longitude)
        request.set("live_period", livePeriod)
        request.set("horizontal_accuracy", horizontalAccuracy)
        request.set("heading", heading)
        request.set("proximity_alert_radius", proximityAlertRadius)
        request.set("reply_markup", replyMarkup)
        return try await self.performMessageOrFlag(request)
    }

    /// Use this method to stop updating a live location message before *live_period* expires.
    /// On success, if the message is not an inline message, the edited ``Message`` is returned,
    /// otherwise *True* is returned.
    @discardableResult
    func stopMessageLiveLocation(
        businessConnectionId: Swift.String? = nil,
        chatId: ChatId? = nil,
        messageId: Swift.Int64? = nil,
        inlineMessageId: Swift.String? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) async throws -> Message? {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("stopMessageLiveLocation")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_id", messageId)
        request.set("inline_message_id", inlineMessageId)
        request.set("reply_markup", replyMarkup)
        return try await self.performMessageOrFlag(request)
    }

    /// Use this method to edit a checklist on behalf of a connected business account. On
    /// success, the edited ``Message`` is returned.
    @discardableResult
    func editMessageChecklist(
        businessConnectionId: Swift.String,
        chatId: ChatId,
        messageId: Swift.Int64,
        checklist: InputChecklist,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("editMessageChecklist")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_id", messageId)
        request.set("checklist", checklist)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to edit only the reply markup of messages. On success, if the edited
    /// message is not an inline message, the edited ``Message`` is returned, otherwise *True*
    /// is returned. Note that business messages that were not sent by the bot and do not
    /// contain an inline keyboard can only be edited within **48 hours** from the time they
    /// were sent.
    @discardableResult
    func editMessageReplyMarkup(
        businessConnectionId: Swift.String? = nil,
        chatId: ChatId? = nil,
        messageId: Swift.Int64? = nil,
        inlineMessageId: Swift.String? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) async throws -> Message? {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("editMessageReplyMarkup")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_id", messageId)
        request.set("inline_message_id", inlineMessageId)
        request.set("reply_markup", replyMarkup)
        return try await self.performMessageOrFlag(request)
    }

    /// Use this method to stop a poll which was sent by the bot. On success, the stopped
    /// ``Poll`` is returned.
    @discardableResult
    func stopPoll(
        chatId: ChatId,
        messageId: Swift.Int64,
        businessConnectionId: Swift.String? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) async throws -> Poll {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("stopPoll")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_id", messageId)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to edit an ephemeral text or rich message. Note that it is not
    /// guaranteed that the user will receive the message edit event, especially if they are
    /// offline. On success, *True* is returned.
    @discardableResult
    func editEphemeralMessageText(
        chatId: ChatId,
        receiverUserId: Swift.Int64,
        ephemeralMessageId: Swift.Int64,
        text: Swift.String? = nil,
        parseMode: ParseMode? = nil,
        entities: [MessageEntity]? = nil,
        richMessage: InputRichMessage? = nil,
        linkPreviewOptions: LinkPreviewOptions? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("editEphemeralMessageText")
        request.set("chat_id", chatId)
        request.set("receiver_user_id", receiverUserId)
        request.set("ephemeral_message_id", ephemeralMessageId)
        request.set("text", text)
        request.set("parse_mode", parseMode?.rawValue)
        request.set("entities", entities)
        request.set("rich_message", richMessage)
        request.set("link_preview_options", linkPreviewOptions)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to edit the media of an ephemeral message. Note that it is not
    /// guaranteed that the user will receive the message edit event, especially if they are
    /// offline. On success, *True* is returned.
    @discardableResult
    func editEphemeralMessageMedia(
        chatId: ChatId,
        receiverUserId: Swift.Int64,
        ephemeralMessageId: Swift.Int64,
        media: InputMedia,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("editEphemeralMessageMedia")
        request.set("chat_id", chatId)
        request.set("receiver_user_id", receiverUserId)
        request.set("ephemeral_message_id", ephemeralMessageId)
        request.set("media", media)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to edit the caption of an ephemeral message. Note that it is not
    /// guaranteed that the user will receive the message edit event, especially if they are
    /// offline. On success, *True* is returned.
    @discardableResult
    func editEphemeralMessageCaption(
        chatId: ChatId,
        receiverUserId: Swift.Int64,
        ephemeralMessageId: Swift.Int64,
        caption: Swift.String? = nil,
        parseMode: ParseMode? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Swift.Bool? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("editEphemeralMessageCaption")
        request.set("chat_id", chatId)
        request.set("receiver_user_id", receiverUserId)
        request.set("ephemeral_message_id", ephemeralMessageId)
        request.set("caption", caption)
        request.set("parse_mode", parseMode?.rawValue)
        request.set("caption_entities", captionEntities)
        request.set("show_caption_above_media", showCaptionAboveMedia)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to edit only the reply markup of an ephemeral message. Note that it is
    /// not guaranteed that the user will receive the message edit event, especially if they are
    /// offline. On success, *True* is returned.
    @discardableResult
    func editEphemeralMessageReplyMarkup(
        chatId: ChatId,
        receiverUserId: Swift.Int64,
        ephemeralMessageId: Swift.Int64,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("editEphemeralMessageReplyMarkup")
        request.set("chat_id", chatId)
        request.set("receiver_user_id", receiverUserId)
        request.set("ephemeral_message_id", ephemeralMessageId)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to delete a message, including service messages, with the following
    /// limitations: - A message can only be deleted if it was sent less than 48 hours ago. -
    /// Service messages about a supergroup, channel, or forum topic creation can't be deleted.
    /// \- A dice message in a private chat can only be deleted if it was sent more than 24 hours
    /// ago. - Bots can delete outgoing messages in private chats, groups, and supergroups. -
    /// Bots can delete incoming messages in private chats. - Bots granted *can_post_messages*
    /// permissions can delete outgoing messages in channels. - If the bot is an administrator
    /// of a group, it can delete any message there. - If the bot has *can_delete_messages*
    /// administrator right in a supergroup or a channel, it can delete any message there. - If
    /// the bot has *can_manage_direct_messages* administrator right in a channel, it can delete
    /// any message in the corresponding direct messages chat. Returns *True* on success.
    @discardableResult
    func deleteMessage(
        chatId: ChatId,
        messageId: Swift.Int64
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("deleteMessage")
        request.set("chat_id", chatId)
        request.set("message_id", messageId)
        return try await self.perform(request)
    }

    /// Use this method to delete multiple messages simultaneously. If some of the specified
    /// messages can't be found, they are skipped. Returns *True* on success.
    @discardableResult
    func deleteMessages(
        chatId: ChatId,
        messageIds: [Swift.Int64]
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("deleteMessages")
        request.set("chat_id", chatId)
        request.set("message_ids", messageIds)
        return try await self.perform(request)
    }

    /// Use this method to delete an ephemeral message. Note that it is not guaranteed that the
    /// user will receive the message deletion event, especially if they are offline. Returns
    /// *True* on success.
    @discardableResult
    func deleteEphemeralMessage(
        chatId: ChatId,
        receiverUserId: Swift.Int64,
        ephemeralMessageId: Swift.Int64
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("deleteEphemeralMessage")
        request.set("chat_id", chatId)
        request.set("receiver_user_id", receiverUserId)
        request.set("ephemeral_message_id", ephemeralMessageId)
        return try await self.perform(request)
    }

    /// Use this method to remove a reaction from a message in a group or a supergroup chat. The
    /// bot must have the 'can_delete_messages' administrator right in the chat. Returns *True*
    /// on success.
    @discardableResult
    func deleteMessageReaction(
        chatId: ChatId,
        messageId: Swift.Int64,
        userId: Swift.Int64? = nil,
        actorChatId: Swift.Int64? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("deleteMessageReaction")
        request.set("chat_id", chatId)
        request.set("message_id", messageId)
        request.set("user_id", userId)
        request.set("actor_chat_id", actorChatId)
        return try await self.perform(request)
    }

    /// Use this method to remove up to 10000 recent reactions in a group or a supergroup chat
    /// added by a given user or chat. The bot must have the 'can_delete_messages' administrator
    /// right in the chat. Returns *True* on success.
    @discardableResult
    func deleteAllMessageReactions(
        chatId: ChatId,
        userId: Swift.Int64? = nil,
        actorChatId: Swift.Int64? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("deleteAllMessageReactions")
        request.set("chat_id", chatId)
        request.set("user_id", userId)
        request.set("actor_chat_id", actorChatId)
        return try await self.perform(request)
    }

    /// Use this method to send rich messages. If the message contains a block with a media
    /// element, then the bot must have the right to send the media to the chat. On success, the
    /// sent ``Message`` is returned.
    @discardableResult
    func sendRichMessage(
        chatId: ChatId,
        richMessage: InputRichMessage,
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        ephemeralMessageParameters: EphemeralMessageParameters? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        suggestedPostParameters: SuggestedPostParameters? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendRichMessage")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("ephemeral_message_parameters", ephemeralMessageParameters)
        request.set("rich_message", richMessage)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("suggested_post_parameters", suggestedPostParameters)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to stream a partial rich message to a user while the message is being
    /// generated. Note that the streamed draft is ephemeral and acts as a temporary 30-second
    /// preview - once the output is finalized, you **must** call `sendRichMessage` with the
    /// complete message to persist it in the user's chat. Returns *True* on success.
    @discardableResult
    func sendRichMessageDraft(
        chatId: Swift.Int64,
        draftId: Swift.Int64,
        richMessage: InputRichMessage,
        messageThreadId: Swift.Int64? = nil,
        canStop: Swift.Bool? = nil,
        keepOnStop: Swift.Bool? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: .id(chatId))
        var request = TelegramRequest("sendRichMessageDraft")
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("draft_id", draftId)
        request.set("rich_message", richMessage)
        request.set("can_stop", canStop)
        request.set("keep_on_stop", keepOnStop)
        return try await self.perform(request)
    }

    /// Use this method to send a game. On success, the sent ``Message`` is returned.
    @discardableResult
    func sendGame(
        chatId: ChatId,
        gameShortName: Swift.String,
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendGame")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("game_short_name", gameShortName)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }
}
