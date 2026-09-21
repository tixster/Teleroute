// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This `object` represents an incoming update. At most **one** of the optional fields can be
/// present in any given update.
public struct Update: Codable, Hashable, Sendable {
    /// The update's unique identifier. Update identifiers start from a certain positive number
    /// and increase sequentially. This identifier becomes especially handy if you're using
    /// `webhooks`, since it allows you to ignore repeated updates or to restore the correct
    /// update sequence, should they get out of order. If there are no new updates for at least
    /// a week, then identifier of the next update will be chosen randomly instead of
    /// sequentially.
    public var updateId: Swift.Int64

    private var messageBox: _IndirectBox<Message>?
    /// *Optional*. New incoming message of any kind - text, photo, sticker, etc.
    public var message: Message? {
        get { self.messageBox?.value }
        set { self.messageBox = newValue.map(_IndirectBox.init) }
    }

    private var editedMessageBox: _IndirectBox<Message>?
    /// *Optional*. New version of a message that is known to the bot and was edited. This
    /// update may at times be triggered by changes to message fields that are either
    /// unavailable or not actively used by your bot.
    public var editedMessage: Message? {
        get { self.editedMessageBox?.value }
        set { self.editedMessageBox = newValue.map(_IndirectBox.init) }
    }

    private var channelPostBox: _IndirectBox<Message>?
    /// *Optional*. New incoming channel post of any kind - text, photo, sticker, etc.
    public var channelPost: Message? {
        get { self.channelPostBox?.value }
        set { self.channelPostBox = newValue.map(_IndirectBox.init) }
    }

    private var editedChannelPostBox: _IndirectBox<Message>?
    /// *Optional*. New version of a channel post that is known to the bot and was edited. This
    /// update may at times be triggered by changes to message fields that are either
    /// unavailable or not actively used by your bot.
    public var editedChannelPost: Message? {
        get { self.editedChannelPostBox?.value }
        set { self.editedChannelPostBox = newValue.map(_IndirectBox.init) }
    }

    private var businessConnectionBox: _IndirectBox<BusinessConnection>?
    /// *Optional*. The bot was connected to or disconnected from a business account, or a user
    /// edited an existing connection with the bot
    public var businessConnection: BusinessConnection? {
        get { self.businessConnectionBox?.value }
        set { self.businessConnectionBox = newValue.map(_IndirectBox.init) }
    }

    private var businessMessageBox: _IndirectBox<Message>?
    /// *Optional*. New message from a connected business account
    public var businessMessage: Message? {
        get { self.businessMessageBox?.value }
        set { self.businessMessageBox = newValue.map(_IndirectBox.init) }
    }

    private var editedBusinessMessageBox: _IndirectBox<Message>?
    /// *Optional*. New version of a message from a connected business account
    public var editedBusinessMessage: Message? {
        get { self.editedBusinessMessageBox?.value }
        set { self.editedBusinessMessageBox = newValue.map(_IndirectBox.init) }
    }

    private var deletedBusinessMessagesBox: _IndirectBox<BusinessMessagesDeleted>?
    /// *Optional*. Messages were deleted from a connected business account
    public var deletedBusinessMessages: BusinessMessagesDeleted? {
        get { self.deletedBusinessMessagesBox?.value }
        set { self.deletedBusinessMessagesBox = newValue.map(_IndirectBox.init) }
    }

    private var guestMessageBox: _IndirectBox<Message>?
    /// *Optional*. New guest message. The bot can use the field *Message.guest_query_id* and
    /// the method `answerGuestQuery` to send a message in response.
    public var guestMessage: Message? {
        get { self.guestMessageBox?.value }
        set { self.guestMessageBox = newValue.map(_IndirectBox.init) }
    }

    private var messageReactionBox: _IndirectBox<MessageReactionUpdated>?
    /// *Optional*. A reaction to a message was changed by a user. The bot must be an
    /// administrator in the chat and must explicitly specify `"message_reaction"` in the list
    /// of *allowed_updates* to receive these updates. The update isn't received for reactions
    /// set by bots.
    public var messageReaction: MessageReactionUpdated? {
        get { self.messageReactionBox?.value }
        set { self.messageReactionBox = newValue.map(_IndirectBox.init) }
    }

    private var messageReactionCountBox: _IndirectBox<MessageReactionCountUpdated>?
    /// *Optional*. Reactions to a message with anonymous reactions were changed. The bot must
    /// be an administrator in the chat and must explicitly specify `"message_reaction_count"`
    /// in the list of *allowed_updates* to receive these updates. The updates are grouped and
    /// can be sent with delay up to a few minutes.
    public var messageReactionCount: MessageReactionCountUpdated? {
        get { self.messageReactionCountBox?.value }
        set { self.messageReactionCountBox = newValue.map(_IndirectBox.init) }
    }

    private var inlineQueryBox: _IndirectBox<InlineQuery>?
    /// *Optional*. New incoming `inline` query
    public var inlineQuery: InlineQuery? {
        get { self.inlineQueryBox?.value }
        set { self.inlineQueryBox = newValue.map(_IndirectBox.init) }
    }

    private var chosenInlineResultBox: _IndirectBox<ChosenInlineResult>?
    /// *Optional*. The result of an `inline` query that was chosen by a user and sent to their
    /// chat partner. Please see our documentation on the feedback collecting for details on how
    /// to enable these updates for your bot.
    public var chosenInlineResult: ChosenInlineResult? {
        get { self.chosenInlineResultBox?.value }
        set { self.chosenInlineResultBox = newValue.map(_IndirectBox.init) }
    }

    private var callbackQueryBox: _IndirectBox<CallbackQuery>?
    /// *Optional*. New incoming callback query
    public var callbackQuery: CallbackQuery? {
        get { self.callbackQueryBox?.value }
        set { self.callbackQueryBox = newValue.map(_IndirectBox.init) }
    }

    private var shippingQueryBox: _IndirectBox<ShippingQuery>?
    /// *Optional*. New incoming shipping query. Only for invoices with flexible price.
    public var shippingQuery: ShippingQuery? {
        get { self.shippingQueryBox?.value }
        set { self.shippingQueryBox = newValue.map(_IndirectBox.init) }
    }

    private var preCheckoutQueryBox: _IndirectBox<PreCheckoutQuery>?
    /// *Optional*. New incoming pre-checkout query. Contains full information about checkout.
    public var preCheckoutQuery: PreCheckoutQuery? {
        get { self.preCheckoutQueryBox?.value }
        set { self.preCheckoutQueryBox = newValue.map(_IndirectBox.init) }
    }

    private var purchasedPaidMediaBox: _IndirectBox<PaidMediaPurchased>?
    /// *Optional*. A user purchased paid media with a non-empty payload sent by the bot in a
    /// non-channel chat
    public var purchasedPaidMedia: PaidMediaPurchased? {
        get { self.purchasedPaidMediaBox?.value }
        set { self.purchasedPaidMediaBox = newValue.map(_IndirectBox.init) }
    }

    private var pollBox: _IndirectBox<Poll>?
    /// *Optional*. New poll state. Bots receive only updates about manually stopped polls and
    /// polls, which are sent by the bot.
    public var poll: Poll? {
        get { self.pollBox?.value }
        set { self.pollBox = newValue.map(_IndirectBox.init) }
    }

    private var pollAnswerBox: _IndirectBox<PollAnswer>?
    /// *Optional*. A user changed their answer in a non-anonymous poll. Bots receive new votes
    /// only in polls that were sent by the bot itself.
    public var pollAnswer: PollAnswer? {
        get { self.pollAnswerBox?.value }
        set { self.pollAnswerBox = newValue.map(_IndirectBox.init) }
    }

    private var myChatMemberBox: _IndirectBox<ChatMemberUpdated>?
    /// *Optional*. The bot's chat member status was updated in a chat. For private chats, this
    /// update is received only when the bot is blocked or unblocked by the user.
    public var myChatMember: ChatMemberUpdated? {
        get { self.myChatMemberBox?.value }
        set { self.myChatMemberBox = newValue.map(_IndirectBox.init) }
    }

    private var chatMemberBox: _IndirectBox<ChatMemberUpdated>?
    /// *Optional*. A chat member's status was updated in a chat. The bot must be an
    /// administrator in the chat and must explicitly specify `"chat_member"` in the list of
    /// *allowed_updates* to receive these updates.
    public var chatMember: ChatMemberUpdated? {
        get { self.chatMemberBox?.value }
        set { self.chatMemberBox = newValue.map(_IndirectBox.init) }
    }

    private var chatJoinRequestBox: _IndirectBox<ChatJoinRequest>?
    /// *Optional*. A request to join the chat has been sent. The bot must have the
    /// *can_invite_users* administrator right in the chat to receive these updates.
    public var chatJoinRequest: ChatJoinRequest? {
        get { self.chatJoinRequestBox?.value }
        set { self.chatJoinRequestBox = newValue.map(_IndirectBox.init) }
    }

    private var chatBoostBox: _IndirectBox<ChatBoostUpdated>?
    /// *Optional*. A chat boost was added or changed. The bot must be an administrator in the
    /// chat to receive these updates.
    public var chatBoost: ChatBoostUpdated? {
        get { self.chatBoostBox?.value }
        set { self.chatBoostBox = newValue.map(_IndirectBox.init) }
    }

    private var removedChatBoostBox: _IndirectBox<ChatBoostRemoved>?
    /// *Optional*. A boost was removed from a chat. The bot must be an administrator in the
    /// chat to receive these updates.
    public var removedChatBoost: ChatBoostRemoved? {
        get { self.removedChatBoostBox?.value }
        set { self.removedChatBoostBox = newValue.map(_IndirectBox.init) }
    }

    private var managedBotBox: _IndirectBox<ManagedBotUpdated>?
    /// *Optional*. A new bot was created to be managed by the bot, or token or owner of a
    /// managed bot was changed
    public var managedBot: ManagedBotUpdated? {
        get { self.managedBotBox?.value }
        set { self.managedBotBox = newValue.map(_IndirectBox.init) }
    }

    private var subscriptionBox: _IndirectBox<BotSubscriptionUpdated>?
    /// *Optional*. User payment subscription has changed
    public var subscription: BotSubscriptionUpdated? {
        get { self.subscriptionBox?.value }
        set { self.subscriptionBox = newValue.map(_IndirectBox.init) }
    }

    private var stoppedMessageGenerationBox: _IndirectBox<MessageGenerationStopped>?
    /// *Optional*. A user asked the bot to stop the generation of a message
    public var stoppedMessageGeneration: MessageGenerationStopped? {
        get { self.stoppedMessageGenerationBox?.value }
        set { self.stoppedMessageGenerationBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        updateId: Swift.Int64,
        message: Message? = nil,
        editedMessage: Message? = nil,
        channelPost: Message? = nil,
        editedChannelPost: Message? = nil,
        businessConnection: BusinessConnection? = nil,
        businessMessage: Message? = nil,
        editedBusinessMessage: Message? = nil,
        deletedBusinessMessages: BusinessMessagesDeleted? = nil,
        guestMessage: Message? = nil,
        messageReaction: MessageReactionUpdated? = nil,
        messageReactionCount: MessageReactionCountUpdated? = nil,
        inlineQuery: InlineQuery? = nil,
        chosenInlineResult: ChosenInlineResult? = nil,
        callbackQuery: CallbackQuery? = nil,
        shippingQuery: ShippingQuery? = nil,
        preCheckoutQuery: PreCheckoutQuery? = nil,
        purchasedPaidMedia: PaidMediaPurchased? = nil,
        poll: Poll? = nil,
        pollAnswer: PollAnswer? = nil,
        myChatMember: ChatMemberUpdated? = nil,
        chatMember: ChatMemberUpdated? = nil,
        chatJoinRequest: ChatJoinRequest? = nil,
        chatBoost: ChatBoostUpdated? = nil,
        removedChatBoost: ChatBoostRemoved? = nil,
        managedBot: ManagedBotUpdated? = nil,
        subscription: BotSubscriptionUpdated? = nil,
        stoppedMessageGeneration: MessageGenerationStopped? = nil
    ) {
        self.updateId = updateId
        self.messageBox = message.map(_IndirectBox.init)
        self.editedMessageBox = editedMessage.map(_IndirectBox.init)
        self.channelPostBox = channelPost.map(_IndirectBox.init)
        self.editedChannelPostBox = editedChannelPost.map(_IndirectBox.init)
        self.businessConnectionBox = businessConnection.map(_IndirectBox.init)
        self.businessMessageBox = businessMessage.map(_IndirectBox.init)
        self.editedBusinessMessageBox = editedBusinessMessage.map(_IndirectBox.init)
        self.deletedBusinessMessagesBox = deletedBusinessMessages.map(_IndirectBox.init)
        self.guestMessageBox = guestMessage.map(_IndirectBox.init)
        self.messageReactionBox = messageReaction.map(_IndirectBox.init)
        self.messageReactionCountBox = messageReactionCount.map(_IndirectBox.init)
        self.inlineQueryBox = inlineQuery.map(_IndirectBox.init)
        self.chosenInlineResultBox = chosenInlineResult.map(_IndirectBox.init)
        self.callbackQueryBox = callbackQuery.map(_IndirectBox.init)
        self.shippingQueryBox = shippingQuery.map(_IndirectBox.init)
        self.preCheckoutQueryBox = preCheckoutQuery.map(_IndirectBox.init)
        self.purchasedPaidMediaBox = purchasedPaidMedia.map(_IndirectBox.init)
        self.pollBox = poll.map(_IndirectBox.init)
        self.pollAnswerBox = pollAnswer.map(_IndirectBox.init)
        self.myChatMemberBox = myChatMember.map(_IndirectBox.init)
        self.chatMemberBox = chatMember.map(_IndirectBox.init)
        self.chatJoinRequestBox = chatJoinRequest.map(_IndirectBox.init)
        self.chatBoostBox = chatBoost.map(_IndirectBox.init)
        self.removedChatBoostBox = removedChatBoost.map(_IndirectBox.init)
        self.managedBotBox = managedBot.map(_IndirectBox.init)
        self.subscriptionBox = subscription.map(_IndirectBox.init)
        self.stoppedMessageGenerationBox = stoppedMessageGeneration.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case updateId = "update_id"
        case messageBox = "message"
        case editedMessageBox = "edited_message"
        case channelPostBox = "channel_post"
        case editedChannelPostBox = "edited_channel_post"
        case businessConnectionBox = "business_connection"
        case businessMessageBox = "business_message"
        case editedBusinessMessageBox = "edited_business_message"
        case deletedBusinessMessagesBox = "deleted_business_messages"
        case guestMessageBox = "guest_message"
        case messageReactionBox = "message_reaction"
        case messageReactionCountBox = "message_reaction_count"
        case inlineQueryBox = "inline_query"
        case chosenInlineResultBox = "chosen_inline_result"
        case callbackQueryBox = "callback_query"
        case shippingQueryBox = "shipping_query"
        case preCheckoutQueryBox = "pre_checkout_query"
        case purchasedPaidMediaBox = "purchased_paid_media"
        case pollBox = "poll"
        case pollAnswerBox = "poll_answer"
        case myChatMemberBox = "my_chat_member"
        case chatMemberBox = "chat_member"
        case chatJoinRequestBox = "chat_join_request"
        case chatBoostBox = "chat_boost"
        case removedChatBoostBox = "removed_chat_boost"
        case managedBotBox = "managed_bot"
        case subscriptionBox = "subscription"
        case stoppedMessageGenerationBox = "stopped_message_generation"
    }
}
