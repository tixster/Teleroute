import Foundation

public extension TelerouteContext {
    /// Resolves the target chat id for a send operation, preferring an explicit
    /// override and falling back to the chat inferred from the current update.
    func resolvedChatId(_ override: Int64?) throws -> Int64 {
        guard let resolved = override ?? self.chatId else {
            throw TelerouteError.chatTargetMissing
        }
        return resolved
    }

    /// Resolves a message id, preferring an explicit override and falling back
    /// to the message carried by the current update.
    func resolvedMessageId(_ override: Int64?) throws -> Int64 {
        guard let resolved = override ?? self.message?.messageId else {
            throw TelerouteError.messageTargetMissing
        }
        return resolved
    }

    // MARK: - Media

    /// Sends a photo to the resolved chat.
    @discardableResult
    func sendPhoto(
        _ photo: FileInput,
        caption: String? = nil,
        to chatId: Int64? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.bot.sendPhoto(
            photo,
            chatId: .id(try self.resolvedChatId(chatId)),
            caption: caption,
            parseMode: parseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Sends a document to the resolved chat.
    @discardableResult
    func sendDocument(
        _ document: FileInput,
        caption: String? = nil,
        to chatId: Int64? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.bot.sendDocument(
            document,
            chatId: .id(try self.resolvedChatId(chatId)),
            caption: caption,
            parseMode: parseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Sends a video to the resolved chat.
    @discardableResult
    func sendVideo(
        _ video: FileInput,
        caption: String? = nil,
        to chatId: Int64? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.bot.sendVideo(
            video,
            chatId: .id(try self.resolvedChatId(chatId)),
            caption: caption,
            parseMode: parseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Sends an animation (GIF) to the resolved chat.
    @discardableResult
    func sendAnimation(
        _ animation: FileInput,
        caption: String? = nil,
        to chatId: Int64? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.bot.sendAnimation(
            animation,
            chatId: .id(try self.resolvedChatId(chatId)),
            caption: caption,
            parseMode: parseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Sends an audio file to the resolved chat.
    @discardableResult
    func sendAudio(
        _ audio: FileInput,
        caption: String? = nil,
        to chatId: Int64? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.bot.sendAudio(
            audio,
            chatId: .id(try self.resolvedChatId(chatId)),
            caption: caption,
            parseMode: parseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Sends a group of media (2–10 items) as an album to the resolved chat.
    @discardableResult
    func sendMediaGroup(
        _ media: [InputMedia],
        to chatId: Int64? = nil
    ) async throws -> [Message] {
        try await self.bot.sendMediaGroup(
            media,
            chatId: .id(try self.resolvedChatId(chatId))
        )
    }

    // MARK: - Message operations

    /// Forwards a message from another chat to the resolved target chat.
    @discardableResult
    func forwardMessage(
        from sourceChatId: Int64,
        messageId: Int64,
        to chatId: Int64? = nil
    ) async throws -> Message {
        try await self.bot.forwardMessage(
            chatId: .id(try self.resolvedChatId(chatId)),
            fromChatId: .id(sourceChatId),
            messageId: messageId
        )
    }

    /// Deletes a message, defaulting to the message carried by the current update.
    func deleteMessage(messageId: Int64? = nil, in chatId: Int64? = nil) async throws {
        try await self.bot.deleteMessage(
            chatId: .id(try self.resolvedChatId(chatId)),
            messageId: try self.resolvedMessageId(messageId)
        )
    }

    /// Edits only the inline keyboard of a message without resending its text.
    ///
    /// Defaults to the message carried by the current update. Throws
    /// ``TelerouteError/messageTargetMissing`` when no message can be resolved.
    func editReplyMarkup(
        _ markup: InlineKeyboardMarkup?,
        messageId: Int64? = nil,
        in chatId: Int64? = nil
    ) async throws {
        try await self.bot.editMessageReplyMarkup(
            chatId: .id(try self.resolvedChatId(chatId)),
            messageId: try self.resolvedMessageId(messageId),
            replyMarkup: markup
        )
    }

    // MARK: - Chat actions

    /// Sends a chat action indicator such as "typing…".
    func sendChatAction(_ action: ChatAction, in chatId: Int64? = nil) async throws {
        try await self.bot.sendChatAction(
            action,
            chatId: .id(try self.resolvedChatId(chatId))
        )
    }
}
