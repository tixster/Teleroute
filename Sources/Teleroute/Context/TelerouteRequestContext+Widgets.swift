import TelegramBotAPI

public extension TelerouteRequestContext {
    /// Sends an HTML widget to an explicit chat or the current context's chat.
    /// In Telegram's production environment widgets are currently restricted
    /// to private chats and automatically have protected content.
    ///
    /// The context's default parse mode applies only when `captionEntities`
    /// is absent. All remaining options pass through to `sendWidget`.
    @discardableResult
    func sendWidget(
        html: String,
        to chat: ChatId? = nil,
        messageThreadId: Int64? = nil,
        width: Int64? = nil,
        height: Int64? = nil,
        publicData: String? = nil,
        chatData: String? = nil,
        caption: String? = nil,
        parseMode: ParseMode? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Bool? = nil,
        allowQueries: Bool? = nil,
        isShared: Bool? = nil,
        disableNotification: Bool? = nil,
        protectContent: Bool? = nil,
        allowPaidBroadcast: Bool? = nil,
        messageEffectId: String? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.bot.sendWidget(
            chatId: try self.resolvedChat(chat),
            html: html,
            messageThreadId: messageThreadId,
            width: width,
            height: height,
            publicData: publicData,
            chatData: chatData,
            caption: caption,
            parseMode: parseMode ?? (captionEntities == nil ? self.defaultParseMode : nil),
            captionEntities: captionEntities,
            showCaptionAboveMedia: showCaptionAboveMedia,
            allowQueries: allowQueries,
            isShared: isShared,
            disableNotification: disableNotification,
            protectContent: protectContent,
            allowPaidBroadcast: allowPaidBroadcast,
            messageEffectId: messageEffectId,
            replyParameters: replyParameters,
            replyMarkup: replyMarkup
        )
    }

    /// Sends a previously created shared widget to the resolved chat.
    /// The same production restrictions and caption defaults as `sendWidget`
    /// apply. Use `context.bot.editSharedWidgetData` to change its public data.
    @discardableResult
    func sendSharedWidget(
        widgetId: String,
        to chat: ChatId? = nil,
        messageThreadId: Int64? = nil,
        chatData: String? = nil,
        caption: String? = nil,
        parseMode: ParseMode? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Bool? = nil,
        disableNotification: Bool? = nil,
        protectContent: Bool? = nil,
        allowPaidBroadcast: Bool? = nil,
        messageEffectId: String? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.bot.sendSharedWidget(
            chatId: try self.resolvedChat(chat),
            widgetId: widgetId,
            messageThreadId: messageThreadId,
            chatData: chatData,
            caption: caption,
            parseMode: parseMode ?? (captionEntities == nil ? self.defaultParseMode : nil),
            captionEntities: captionEntities,
            showCaptionAboveMedia: showCaptionAboveMedia,
            disableNotification: disableNotification,
            protectContent: protectContent,
            allowPaidBroadcast: allowPaidBroadcast,
            messageEffectId: messageEffectId,
            replyParameters: replyParameters,
            replyMarkup: replyMarkup
        )
    }

    /// Answers the current widget or shared-widget query within Telegram's
    /// 15-second deadline. Teleroute does not answer widget queries automatically.
    /// This returns data to the requesting widget without changing its stored data.
    @discardableResult
    func answerWidgetQuery(data: String? = nil) async throws -> Bool {
        guard let queryId = self.widgetQuery?.id ?? self.sharedWidgetQuery?.id else {
            throw TelerouteError.widgetQueryMissing
        }
        return try await self.bot.answerWidgetQuery(widgetQueryId: queryId, data: data)
    }
}
