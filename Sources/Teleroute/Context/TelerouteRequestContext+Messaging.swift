import Foundation
import TelegramBotAPI

// MARK: - Messaging helpers available on every request context

public extension TelerouteRequestContext {
    /// Replies to the current message: sends to its chat with
    /// `reply_parameters` attached so the reply is visibly linked.
    /// Falls back to a plain send when the update carries no message.
    ///
    /// - Parameters:
    ///   - text: Text of the reply.
    ///   - parseMode: Parse mode for the text; defaults to the configured
    ///     ``TelerouteConfiguration/defaultParseMode``.
    ///   - replyMarkup: Optional keyboard attached to the reply.
    ///   - quote: Optional exact passage of the original message to
    ///     highlight in the reply.
    func reply(
        _ text: String,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil,
        quote: String? = nil
    ) async throws {
        guard let message = self.message else {
            try await self.send(text, parseMode: parseMode, replyMarkup: replyMarkup)
            return
        }
        try await self.bot.sendMessage(
            chatId: .id(message.chat.id),
            text: text,
            parseMode: parseMode ?? self.defaultParseMode,
            replyParameters: .init(messageId: message.messageId, quote: quote),
            replyMarkup: replyMarkup
        )
    }

    /// Sends a message to the supplied chat or to the chat inferred from the
    /// current update.
    func send(
        _ text: String,
        to chat: ChatId? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil,
        silent: Bool? = nil,
        protectContent: Bool? = nil,
        threadId: Int64? = nil
    ) async throws {
        try await self.bot.sendMessage(
            chatId: try self.resolvedChat(chat),
            text: text,
            messageThreadId: threadId,
            parseMode: parseMode ?? self.defaultParseMode,
            disableNotification: silent,
            protectContent: protectContent,
            replyMarkup: replyMarkup
        )
    }

    /// Edits the current message.
    ///
    /// This helper requires a concrete accessible `Message` and will throw
    /// ``TelerouteError/messageTargetMissing`` when the update does not carry one.
    func edit(
        _ text: String,
        parseMode: ParseMode? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) async throws {
        guard let message = self.message else {
            throw TelerouteError.messageTargetMissing
        }
        try await self.bot.editMessageText(
            chatId: .id(message.chat.id),
            messageId: message.messageId,
            text: text,
            parseMode: parseMode ?? self.defaultParseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Edits the caption of the current (or an explicit) message.
    func editCaption(
        _ caption: String?,
        parseMode: ParseMode? = nil,
        messageId: Int64? = nil,
        in chat: ChatId? = nil
    ) async throws {
        try await self.bot.editMessageCaption(
            chatId: try self.resolvedChat(chat),
            messageId: try self.resolvedMessageId(messageId),
            caption: caption,
            parseMode: parseMode ?? self.defaultParseMode
        )
    }

    /// Edits only the inline keyboard of a message without resending its text.
    func editReplyMarkup(
        _ markup: InlineKeyboardMarkup?,
        messageId: Int64? = nil,
        in chat: ChatId? = nil
    ) async throws {
        try await self.bot.editMessageReplyMarkup(
            chatId: try self.resolvedChat(chat),
            messageId: try self.resolvedMessageId(messageId),
            replyMarkup: markup
        )
    }

    /// Deletes a message, defaulting to the message carried by the current update.
    func deleteMessage(messageId: Int64? = nil, in chat: ChatId? = nil) async throws {
        try await self.bot.deleteMessage(
            chatId: try self.resolvedChat(chat),
            messageId: try self.resolvedMessageId(messageId)
        )
    }

    /// Forwards a message from another chat to the resolved target chat.
    @discardableResult
    func forwardMessage(
        from source: ChatId,
        messageId: Int64,
        to chat: ChatId? = nil
    ) async throws -> Message {
        try await self.bot.forwardMessage(
            chatId: try self.resolvedChat(chat),
            fromChatId: source,
            messageId: messageId
        )
    }

    /// Copies a message (without the forward header) to the resolved chat.
    @discardableResult
    func copyMessage(
        from source: ChatId,
        messageId: Int64,
        to chat: ChatId? = nil,
        caption: String? = nil
    ) async throws -> MessageId {
        try await self.bot.copyMessage(
            chatId: try self.resolvedChat(chat),
            fromChatId: source,
            messageId: messageId,
            caption: caption
        )
    }

    /// Sets an emoji reaction on the current message.
    func react(_ emoji: String, big: Bool? = nil) async throws {
        guard let message = self.message else {
            throw TelerouteError.messageTargetMissing
        }
        try await self.bot.setMessageReaction(
            chatId: .id(message.chat.id),
            messageId: message.messageId,
            reaction: [.emoji(.init(emoji: emoji))],
            isBig: big
        )
    }

    /// Pins a message in the resolved chat.
    func pinMessage(
        messageId: Int64? = nil,
        in chat: ChatId? = nil,
        silent: Bool? = nil
    ) async throws {
        try await self.bot.pinChatMessage(
            chatId: try self.resolvedChat(chat),
            messageId: try self.resolvedMessageId(messageId),
            disableNotification: silent
        )
    }

    /// Unpins a message (or the most recent pin) in the resolved chat.
    func unpinMessage(messageId: Int64? = nil, in chat: ChatId? = nil) async throws {
        try await self.bot.unpinChatMessage(
            chatId: try self.resolvedChat(chat),
            messageId: messageId
        )
    }

    /// Sends a chat action indicator such as "typing…".
    func sendChatAction(_ action: ChatAction, in chat: ChatId? = nil) async throws {
        try await self.bot.sendChatAction(
            chatId: try self.resolvedChat(chat),
            action: action
        )
    }

    /// Shows "typing…" in the resolved chat.
    func typing(in chat: ChatId? = nil) async throws {
        try await self.sendChatAction(.typing, in: chat)
    }

    /// Shows a chat action while the supplied work runs.
    func withChatAction<Result: Sendable>(
        _ action: ChatAction,
        in chat: ChatId? = nil,
        while work: () async throws -> Result
    ) async throws -> Result {
        try await self.sendChatAction(action, in: chat)
        return try await work()
    }
}

// MARK: - Callback answering

public extension TelerouteRequestContext {
    /// Answers the current callback query.
    func answerCallbackQuery(
        _ text: String? = nil,
        showAlert: Bool? = nil,
        url: String? = nil,
        cacheTime: Int64? = nil
    ) async throws {
        guard let callbackQuery = self.callbackQuery else {
            throw TelerouteError.callbackQueryMissing
        }
        self.coreContext.responderState.markCallbackAnswered()
        try await self.bot.answerCallbackQuery(
            callbackQueryId: callbackQuery.id,
            text: text,
            showAlert: showAlert,
            url: url,
            cacheTime: cacheTime
        )
    }

    /// Suppresses the automatic empty callback-query answer for this update,
    /// for handlers that intentionally leave the query unanswered.
    func skipCallbackAutoAnswer() {
        self.coreContext.responderState.markCallbackAnswered()
    }
}

// MARK: - Chat management

public extension TelerouteRequestContext {
    /// Information about a member of the resolved chat.
    func getChatMember(userId: Int64, in chat: ChatId? = nil) async throws -> ChatMember {
        try await self.bot.getChatMember(
            chatId: try self.resolvedChat(chat),
            userId: userId
        )
    }

    /// Whether the given (or current) user administers the resolved chat.
    func isAdmin(userId: Int64? = nil, in chat: ChatId? = nil) async throws -> Bool {
        guard let userId = userId ?? self.userId else { return false }
        switch try await self.getChatMember(userId: userId, in: chat) {
        case .creator, .administrator:
            return true
        default:
            return false
        }
    }

    /// Bans a user in the resolved chat.
    func banMember(
        _ userId: Int64,
        in chat: ChatId? = nil,
        untilDate: Int64? = nil,
        revokeMessages: Bool? = nil
    ) async throws {
        try await self.bot.banChatMember(
            chatId: try self.resolvedChat(chat),
            userId: userId,
            untilDate: untilDate,
            revokeMessages: revokeMessages
        )
    }

    /// Unbans a user in the resolved chat.
    func unbanMember(
        _ userId: Int64,
        in chat: ChatId? = nil,
        onlyIfBanned: Bool? = nil
    ) async throws {
        try await self.bot.unbanChatMember(
            chatId: try self.resolvedChat(chat),
            userId: userId,
            onlyIfBanned: onlyIfBanned
        )
    }

    /// Restricts a user in the resolved chat.
    func restrictMember(
        _ userId: Int64,
        permissions: ChatPermissions,
        in chat: ChatId? = nil,
        untilDate: Int64? = nil
    ) async throws {
        try await self.bot.restrictChatMember(
            chatId: try self.resolvedChat(chat),
            userId: userId,
            permissions: permissions,
            untilDate: untilDate
        )
    }

    /// Approves the update's chat join request (or an explicit user's).
    func approveJoinRequest(userId: Int64? = nil, in chat: ChatId? = nil) async throws {
        guard let userId = userId ?? self.update.chatJoinRequest?.from.id else {
            throw TelerouteError.chatTargetMissing
        }
        try await self.bot.approveChatJoinRequest(
            chatId: try self.resolvedChat(chat),
            userId: userId
        )
    }

    /// Declines the update's chat join request (or an explicit user's).
    func declineJoinRequest(userId: Int64? = nil, in chat: ChatId? = nil) async throws {
        guard let userId = userId ?? self.update.chatJoinRequest?.from.id else {
            throw TelerouteError.chatTargetMissing
        }
        try await self.bot.declineChatJoinRequest(
            chatId: try self.resolvedChat(chat),
            userId: userId
        )
    }
}
