import Foundation

/// Which `Update` field carried the message of a message-bearing update.
public enum TelerouteMessageSource: Sendable, Hashable, CaseIterable {
    case message
    case edited
    case channelPost
    case editedChannelPost
    case business
    case editedBusiness

    /// The update kind delivering messages from this source.
    var updateKind: UpdateKind {
        switch self {
        case .message: .message
        case .edited: .editedMessage
        case .channelPost: .channelPost
        case .editedChannelPost: .editedChannelPost
        case .business: .businessMessage
        case .editedBusiness: .editedBusinessMessage
        }
    }
}

/// Values derived from a Telegram update and reused throughout one routing pass.
struct TelerouteParsedUpdate: Sendable {
    let update: Update
    /// The update's kind, when it carries a known payload.
    let kind: UpdateKind?
    let callbackQuery: CallbackQuery?
    let callbackData: String?
    let callbackComponents: [String]?
    let message: Message?
    /// Which update field produced ``message`` (nil for callback-hosted messages).
    let messageSource: TelerouteMessageSource?
    let command: TelerouteCommandMatch?
    let chatId: Int64?
    let chatType: ChatType?
    let userId: Int64?
    /// The Telegram user behind this update, for every kind that carries one.
    let user: User?
    let flowKey: TelerouteFlowKey?
    let routeKind: TelerouteEvent.RouteKind

    init(_ update: Update) {
        let kind = update.kind
        let callbackQuery = update.callbackQuery
        let callbackData = callbackQuery?.data
        let (message, messageSource) = Self.resolveMessage(from: update)
        let command = TelerouteCommandExtractor.extract(from: update)
        let identity = Self.resolveIdentity(
            from: update,
            message: message,
            callbackQuery: callbackQuery
        )

        self.update = update
        self.kind = kind
        self.callbackQuery = callbackQuery
        self.callbackData = callbackData
        self.callbackComponents = callbackData.map(TeleroutePath.components(from:))
        self.message = message
        self.messageSource = messageSource
        self.command = command
        self.chatId = identity.chatId
        self.chatType = identity.chatType
        self.user = identity.user
        self.userId = identity.user?.id
        self.flowKey = identity.chatId.map {
            TelerouteFlowKey(chatId: $0, userId: identity.user?.id)
        }
        self.routeKind = if command != nil {
            .command
        } else if callbackData != nil {
            .callback
        } else if message != nil {
            .message
        } else if let kind {
            .update(kind)
        } else {
            .unknown
        }
    }

    private static func resolveMessage(
        from update: Update
    ) -> (Message?, TelerouteMessageSource?) {
        if let message = update.message { return (message, .message) }
        if let message = update.editedMessage { return (message, .edited) }
        if let message = update.channelPost { return (message, .channelPost) }
        if let message = update.editedChannelPost { return (message, .editedChannelPost) }
        if let message = update.businessMessage { return (message, .business) }
        if let message = update.editedBusinessMessage { return (message, .editedBusiness) }
        if let message = update.callbackQuery?.message?.accessibleMessage {
            return (message, nil)
        }
        return (nil, nil)
    }

    /// Extracts the chat/user identity for every update kind that carries one,
    /// so replay protection, flow keys, and metrics work beyond messages.
    private static func resolveIdentity(
        from update: Update,
        message: Message?,
        callbackQuery: CallbackQuery?
    ) -> (chatId: Int64?, chatType: ChatType?, user: User?) {
        if let callbackQuery {
            let chat = callbackQuery.message?.chat
            return (chat?.id, chat?.type, callbackQuery.from)
        }
        if let message {
            return (message.chat.id, message.chat.type, message.from)
        }
        if let updated = update.chatMember ?? update.myChatMember {
            return (updated.chat.id, updated.chat.type, updated.from)
        }
        if let request = update.chatJoinRequest {
            return (request.chat.id, request.chat.type, request.from)
        }
        if let reaction = update.messageReaction {
            return (reaction.chat.id, reaction.chat.type, reaction.user)
        }
        if let reactionCount = update.messageReactionCount {
            return (reactionCount.chat.id, reactionCount.chat.type, nil)
        }
        if let boost = update.chatBoost {
            return (boost.chat.id, boost.chat.type, nil)
        }
        if let removedBoost = update.removedChatBoost {
            return (removedBoost.chat.id, removedBoost.chat.type, nil)
        }
        if let deleted = update.deletedBusinessMessages {
            return (deleted.chat.id, deleted.chat.type, nil)
        }
        if let query = update.inlineQuery {
            return (nil, nil, query.from)
        }
        if let chosen = update.chosenInlineResult {
            return (nil, nil, chosen.from)
        }
        if let shipping = update.shippingQuery {
            return (nil, nil, shipping.from)
        }
        if let preCheckout = update.preCheckoutQuery {
            return (nil, nil, preCheckout.from)
        }
        if let paidMedia = update.purchasedPaidMedia {
            return (nil, nil, paidMedia.from)
        }
        if let pollAnswer = update.pollAnswer {
            return (pollAnswer.voterChat?.id, pollAnswer.voterChat?.type, pollAnswer.user)
        }
        if let connection = update.businessConnection {
            return (nil, nil, connection.user)
        }
        return (nil, nil, nil)
    }
}

// MARK: - Logging

extension TelerouteParsedUpdate {
    /// Request-scoped logger metadata describing this update.
    ///
    /// Built here rather than in the runtime so that every context construction
    /// site — the runtime's own and the flow coordinator's — describes an update
    /// the same way.
    var loggerMetadata: Logger.Metadata {
        var metadata: Logger.Metadata = [
            "update_id": .stringConvertible(self.update.updateId),
            "chat_id": .string(self.chatId.map(String.init) ?? "none"),
            "user_id": .string(self.userId.map(String.init) ?? "none"),
        ]

        if let command = self.command {
            metadata["route_kind"] = .string("command")
            metadata["command"] = .string(command.name)
        } else if let callbackData = self.callbackData {
            metadata["route_kind"] = .string("callback")
            metadata["callback_data"] = .string(callbackData)
        } else if let text = self.message?.text, text.isEmpty == false {
            metadata["route_kind"] = .string("message")
            metadata["message_text"] = .string(text)
        } else {
            metadata["route_kind"] = .string("unknown")
        }

        return metadata
    }

    /// A logger carrying this update's metadata.
    func logger(from base: Logger) -> Logger {
        var logger = base
        for (key, value) in self.loggerMetadata {
            logger[metadataKey: key] = value
        }
        return logger
    }
}
