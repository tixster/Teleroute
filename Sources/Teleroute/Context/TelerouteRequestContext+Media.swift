import Foundation

// MARK: - Media helpers available on every request context

public extension TelerouteRequestContext {
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
            chatId: try self.resolvedChat(chat),
            photo: photo,
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
            chatId: try self.resolvedChat(chat),
            document: document,
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
            chatId: try self.resolvedChat(chat),
            video: video,
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
            chatId: try self.resolvedChat(chat),
            animation: animation,
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
            chatId: try self.resolvedChat(chat),
            audio: audio,
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
            chatId: try self.resolvedChat(chat),
            voice: voice,
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
            chatId: try self.resolvedChat(chat),
            videoNote: videoNote,
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
            chatId: try self.resolvedChat(chat),
            sticker: sticker,
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
            chatId: try self.resolvedChat(chat),
            latitude: latitude,
            longitude: longitude
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
            chatId: try self.resolvedChat(chat),
            phoneNumber: phoneNumber,
            firstName: firstName,
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
