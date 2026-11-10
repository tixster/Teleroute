import Foundation

// MARK: - Media helpers available on every request context

public extension TelerouteRequestContext {
    /// Runs any Bot API operation against the chat resolved from this update.
    ///
    /// The media helpers below cover the common arguments. When you need one
    /// they do not expose — `hasSpoiler`, `replyParameters`, `captionEntities`,
    /// `showCaptionAboveMedia`, and the rest of the generated surface — reach
    /// for the full client without hand-rolling chat resolution:
    ///
    /// ```swift
    /// try await context.withResolvedChat { bot, chatId in
    ///     try await bot.sendPhoto(
    ///         photo: .upload(filename: "spoiler.png", data: png),
    ///         chatId: chatId,
    ///         caption: "Careful",
    ///         hasSpoiler: true,
    ///         replyParameters: .init(messageId: try context.resolvedMessageId())
    ///     )
    /// }
    /// ```
    ///
    /// - Throws: ``TelerouteError/chatTargetMissing`` when the update carries
    ///   no chat and no override is supplied.
    @discardableResult
    func withResolvedChat<Result>(
        _ chat: ChatId? = nil,
        _ body: (TelegramBotClient, ChatId) async throws -> Result
    ) async throws -> Result {
        try await body(self.bot, try self.resolvedChat(chat))
    }

    /// Sends a photo to the resolved chat.
    @discardableResult
    func sendPhoto(
        _ photo: FileInput,
        caption: String? = nil,
        to chat: ChatId? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.bot.sendPhoto(
            photo: photo,
            chatId: try self.resolvedChat(chat),
            caption: caption,
            parseMode: parseMode ?? self.defaultParseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Sends a document to the resolved chat.
    @discardableResult
    func sendDocument(
        _ document: FileInput,
        caption: String? = nil,
        to chat: ChatId? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.bot.sendDocument(
            document: document,
            chatId: try self.resolvedChat(chat),
            caption: caption,
            parseMode: parseMode ?? self.defaultParseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Sends a video to the resolved chat.
    @discardableResult
    func sendVideo(
        _ video: FileInput,
        caption: String? = nil,
        to chat: ChatId? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.bot.sendVideo(
            video: video,
            chatId: try self.resolvedChat(chat),
            caption: caption,
            parseMode: parseMode ?? self.defaultParseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Sends an animation (GIF) to the resolved chat.
    @discardableResult
    func sendAnimation(
        _ animation: FileInput,
        caption: String? = nil,
        to chat: ChatId? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.bot.sendAnimation(
            animation: animation,
            chatId: try self.resolvedChat(chat),
            caption: caption,
            parseMode: parseMode ?? self.defaultParseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Sends an audio file to the resolved chat.
    @discardableResult
    func sendAudio(
        _ audio: FileInput,
        caption: String? = nil,
        to chat: ChatId? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.bot.sendAudio(
            audio: audio,
            chatId: try self.resolvedChat(chat),
            caption: caption,
            parseMode: parseMode ?? self.defaultParseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Sends a voice note to the resolved chat.
    @discardableResult
    func sendVoice(
        _ voice: FileInput,
        caption: String? = nil,
        to chat: ChatId? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.bot.sendVoice(
            voice: voice,
            chatId: try self.resolvedChat(chat),
            caption: caption,
            parseMode: parseMode ?? self.defaultParseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Sends a video note to the resolved chat.
    @discardableResult
    func sendVideoNote(
        _ videoNote: FileInput,
        to chat: ChatId? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.bot.sendVideoNote(
            videoNote: videoNote,
            chatId: try self.resolvedChat(chat),
            replyMarkup: replyMarkup
        )
    }

    /// Sends a sticker to the resolved chat.
    @discardableResult
    func sendSticker(
        _ sticker: FileInput,
        to chat: ChatId? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.bot.sendSticker(
            sticker: sticker,
            chatId: try self.resolvedChat(chat),
            replyMarkup: replyMarkup
        )
    }

    /// Sends a group of media (2–10 items) as an album to the resolved chat.
    @discardableResult
    func sendMediaGroup(
        _ media: [MediaGroupInputMedia],
        to chat: ChatId? = nil
    ) async throws -> [Message] {
        try await self.bot.sendMediaGroup(
            chatId: try self.resolvedChat(chat),
            media: media
        )
    }

    /// Sends a location to the resolved chat.
    @discardableResult
    func sendLocation(
        latitude: Double,
        longitude: Double,
        to chat: ChatId? = nil
    ) async throws -> Message {
        try await self.bot.sendLocation(
            latitude: latitude,
            longitude: longitude,
            chatId: try self.resolvedChat(chat)
        )
    }

    /// Sends a contact card to the resolved chat.
    @discardableResult
    func sendContact(
        phoneNumber: String,
        firstName: String,
        lastName: String? = nil,
        to chat: ChatId? = nil
    ) async throws -> Message {
        try await self.bot.sendContact(
            phoneNumber: phoneNumber,
            firstName: firstName,
            chatId: try self.resolvedChat(chat),
            lastName: lastName
        )
    }

    /// Sends a dice animation to the resolved chat.
    @discardableResult
    func sendDice(
        _ emoji: String? = nil,
        to chat: ChatId? = nil
    ) async throws -> Message {
        try await self.bot.sendDice(
            chatId: try self.resolvedChat(chat),
            emoji: emoji
        )
    }
}
