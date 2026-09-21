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
        self.userId = identity.userId
        self.flowKey = identity.chatId.map {
            TelerouteFlowKey(chatId: $0, userId: identity.userId)
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
    ) -> (chatId: Int64?, chatType: ChatType?, userId: Int64?) {
        if let callbackQuery {
            let chat = callbackQuery.message?.chat
            return (chat?.id, chat?.type, callbackQuery.from.id)
        }
        if let message {
            return (message.chat.id, message.chat.type, message.from?.id)
        }
        if let updated = update.chatMember ?? update.myChatMember {
            return (updated.chat.id, updated.chat.type, updated.from.id)
        }
        if let request = update.chatJoinRequest {
            return (request.chat.id, request.chat.type, request.from.id)
        }
        if let reaction = update.messageReaction {
            return (reaction.chat.id, reaction.chat.type, reaction.user?.id)
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
            return (nil, nil, query.from.id)
        }
        if let chosen = update.chosenInlineResult {
            return (nil, nil, chosen.from.id)
        }
        if let shipping = update.shippingQuery {
            return (nil, nil, shipping.from.id)
        }
        if let preCheckout = update.preCheckoutQuery {
            return (nil, nil, preCheckout.from.id)
        }
        if let paidMedia = update.purchasedPaidMedia {
            return (nil, nil, paidMedia.from.id)
        }
        if let pollAnswer = update.pollAnswer {
            return (pollAnswer.voterChat?.id, pollAnswer.voterChat?.type, pollAnswer.user?.id)
        }
        if let connection = update.businessConnection {
            return (nil, nil, connection.user.id)
        }
        return (nil, nil, nil)
    }
}
