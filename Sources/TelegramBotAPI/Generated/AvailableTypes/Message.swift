// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a message.
public struct Message: Codable, Hashable, Sendable {
    /// Unique message identifier inside this chat; 0 for ephemeral messages. In specific
    /// instances (e.g., a message containing a video sent to a big chat), the server might
    /// automatically schedule a message instead of sending it immediately. In such cases, this
    /// field will be 0 and the relevant message will be unusable until it is actually sent.
    public var messageId: Swift.Int64

    /// *Optional*. Unique identifier of a message thread or forum topic to which the message
    /// belongs; for supergroups and private chats only
    public var messageThreadId: Swift.Int64?

    private var directMessagesTopicBox: _IndirectBox<DirectMessagesTopic>?
    /// *Optional*. Information about the direct messages chat topic that contains the message
    public var directMessagesTopic: DirectMessagesTopic? {
        get { self.directMessagesTopicBox?.value }
        set { self.directMessagesTopicBox = newValue.map(_IndirectBox.init) }
    }

    private var fromBox: _IndirectBox<User>?
    /// *Optional*. Sender of the message; may be empty for messages sent to channels. For
    /// backward compatibility, if the message was sent on behalf of a chat, the field contains
    /// a fake sender user in non-channel chats.
    public var from: User? {
        get { self.fromBox?.value }
        set { self.fromBox = newValue.map(_IndirectBox.init) }
    }

    private var senderChatBox: _IndirectBox<Chat>?
    /// *Optional*. Sender of the message when sent on behalf of a chat. For example, the
    /// supergroup itself for messages sent by its anonymous administrators or a linked channel
    /// for messages automatically forwarded to the channel's discussion group. For backward
    /// compatibility, if the message was sent on behalf of a chat, the field *from* contains a
    /// fake sender user in non-channel chats.
    public var senderChat: Chat? {
        get { self.senderChatBox?.value }
        set { self.senderChatBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. If the sender of the message boosted the chat, the number of boosts added by
    /// the user
    public var senderBoostCount: Swift.Int64?

    private var senderBusinessBotBox: _IndirectBox<User>?
    /// *Optional*. The bot that actually sent the message on behalf of the business account.
    /// Available only for outgoing messages sent on behalf of the connected business account.
    public var senderBusinessBot: User? {
        get { self.senderBusinessBotBox?.value }
        set { self.senderBusinessBotBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Tag or custom title of the sender of the message; for supergroups only
    public var senderTag: Swift.String?

    private var receiverUserBox: _IndirectBox<User>?
    /// *Optional*. For ephemeral messages, the user who received the message
    public var receiverUser: User? {
        get { self.receiverUserBox?.value }
        set { self.receiverUserBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. For ephemeral messages, identifier of the ephemeral message inside this
    /// chat. The identifier may be reused for another ephemeral message after the message is
    /// deleted or expires.
    public var ephemeralMessageId: Swift.Int64?

    /// Date the message was sent in Unix time. It is always a positive number, representing a
    /// valid date.
    public var date: Swift.Int64

    /// *Optional*. The unique identifier for the guest query. Use this identifier with the
    /// method `answerGuestQuery` to send a response message. If non-empty, the message belongs
    /// to the chat where the guest bot was summoned, which may not coincide with other existing
    /// bot chats sharing the same identifier.
    public var guestQueryId: Swift.String?

    /// *Optional*. Unique identifier of the business connection from which the message was
    /// received. If non-empty, the message belongs to a chat of the corresponding business
    /// account that is independent from any potential bot chat which might share the same
    /// identifier.
    public var businessConnectionId: Swift.String?

    private var chatBox: _IndirectBox<Chat>
    /// Chat the message belongs to
    public var chat: Chat {
        get { self.chatBox.value }
        set { self.chatBox = _IndirectBox(newValue) }
    }

    private var forwardOriginBox: _IndirectBox<MessageOrigin>?
    /// *Optional*. Information about the original message for forwarded messages
    public var forwardOrigin: MessageOrigin? {
        get { self.forwardOriginBox?.value }
        set { self.forwardOriginBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. *True*, if the message is sent to a topic in a forum supergroup or a private
    /// chat with the bot
    public var isTopicMessage: Swift.Bool?

    /// *Optional*. *True*, if the message is a channel post that was automatically forwarded to
    /// the connected discussion group
    public var isAutomaticForward: Swift.Bool?

    private var replyToMessageBox: _IndirectBox<Message>?
    /// *Optional*. For replies in the same chat and message thread, the original message. Note
    /// that the ``Message`` object in this field will not contain further *reply_to_message*
    /// fields even if it itself is a reply. If the message is a reply to an ephemeral message,
    /// then this field may be omitted.
    public var replyToMessage: Message? {
        get { self.replyToMessageBox?.value }
        set { self.replyToMessageBox = newValue.map(_IndirectBox.init) }
    }

    private var externalReplyBox: _IndirectBox<ExternalReplyInfo>?
    /// *Optional*. Information about the message that is being replied to, which may come from
    /// another chat or forum topic
    public var externalReply: ExternalReplyInfo? {
        get { self.externalReplyBox?.value }
        set { self.externalReplyBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. For replies that quote part of the original message, the quoted part of the
    /// message
    public var quote: TextQuote?

    private var replyToStoryBox: _IndirectBox<Story>?
    /// *Optional*. For replies to a story, the original story
    public var replyToStory: Story? {
        get { self.replyToStoryBox?.value }
        set { self.replyToStoryBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Identifier of the specific checklist task that is being replied to
    public var replyToChecklistTaskId: Swift.Int64?

    /// *Optional*. Persistent identifier of the specific poll option that is being replied to
    public var replyToPollOptionId: Swift.String?

    private var viaBotBox: _IndirectBox<User>?
    /// *Optional*. Bot through which the message was sent
    public var viaBot: User? {
        get { self.viaBotBox?.value }
        set { self.viaBotBox = newValue.map(_IndirectBox.init) }
    }

    private var guestBotCallerUserBox: _IndirectBox<User>?
    /// *Optional*. For a message sent by a guest bot, this is the user whose original message
    /// triggered the bot's response
    public var guestBotCallerUser: User? {
        get { self.guestBotCallerUserBox?.value }
        set { self.guestBotCallerUserBox = newValue.map(_IndirectBox.init) }
    }

    private var guestBotCallerChatBox: _IndirectBox<Chat>?
    /// *Optional*. For a message sent by a guest bot, this is the chat whose original message
    /// triggered the bot's response
    public var guestBotCallerChat: Chat? {
        get { self.guestBotCallerChatBox?.value }
        set { self.guestBotCallerChatBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Date the message was last edited in Unix time
    public var editDate: Swift.Int64?

    /// *Optional*. *True*, if the message can't be forwarded
    public var hasProtectedContent: Swift.Bool?

    /// *Optional*. *True*, if the message was sent by an implicit action, for example, as an
    /// away or a greeting business message, or as a scheduled message
    public var isFromOffline: Swift.Bool?

    /// *Optional*. *True*, if the message is a paid post. Note that such posts must not be
    /// deleted for 24 hours to receive the payment and can't be edited.
    public var isPaidPost: Swift.Bool?

    /// *Optional*. The unique identifier inside this chat of a media message group this message
    /// belongs to
    public var mediaGroupId: Swift.String?

    /// *Optional*. Signature of the post author for messages in channels, or the custom title
    /// of an anonymous group administrator
    public var authorSignature: Swift.String?

    /// *Optional*. The number of Telegram Stars that were paid by the sender of the message to
    /// send it
    public var paidStarCount: Swift.Int64?

    /// *Optional*. For text messages, the actual UTF-8 text of the message
    public var text: Swift.String?

    /// *Optional*. For text messages, special entities like usernames, URLs, bot commands, etc.
    /// that appear in the text
    public var entities: [MessageEntity]?

    /// *Optional*. Options used for link preview generation for the message, if it is a text
    /// message and link preview options were changed
    public var linkPreviewOptions: LinkPreviewOptions?

    /// *Optional*. Information about suggested post parameters if the message is a suggested
    /// post in a channel direct messages chat. If the message is an approved or declined
    /// suggested post, then it can't be edited.
    public var suggestedPostInfo: SuggestedPostInfo?

    /// *Optional*. Unique identifier of the message effect added to the message
    public var effectId: Swift.String?

    /// *Optional*. Message is a rich formatted message
    public var richMessage: RichMessage?

    private var animationBox: _IndirectBox<Animation>?
    /// *Optional*. Message is an animation, information about the animation. For backward
    /// compatibility, when this field is set, the *document* field will also be set.
    public var animation: Animation? {
        get { self.animationBox?.value }
        set { self.animationBox = newValue.map(_IndirectBox.init) }
    }

    private var audioBox: _IndirectBox<Audio>?
    /// *Optional*. Message is an audio file, information about the file
    public var audio: Audio? {
        get { self.audioBox?.value }
        set { self.audioBox = newValue.map(_IndirectBox.init) }
    }

    private var documentBox: _IndirectBox<Document>?
    /// *Optional*. Message is a general file, information about the file
    public var document: Document? {
        get { self.documentBox?.value }
        set { self.documentBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Message is a live photo, information about the live photo. For backward
    /// compatibility, when this field is set, the *photo* field will also be set.
    public var livePhoto: LivePhoto?

    /// *Optional*. Message contains paid media; information about the paid media
    public var paidMedia: PaidMediaInfo?

    /// *Optional*. Message is a photo, available sizes of the photo
    public var photo: [PhotoSize]?

    private var stickerBox: _IndirectBox<Sticker>?
    /// *Optional*. Message is a sticker, information about the sticker
    public var sticker: Sticker? {
        get { self.stickerBox?.value }
        set { self.stickerBox = newValue.map(_IndirectBox.init) }
    }

    private var storyBox: _IndirectBox<Story>?
    /// *Optional*. Message is a forwarded story
    public var story: Story? {
        get { self.storyBox?.value }
        set { self.storyBox = newValue.map(_IndirectBox.init) }
    }

    private var videoBox: _IndirectBox<Video>?
    /// *Optional*. Message is a video, information about the video
    public var video: Video? {
        get { self.videoBox?.value }
        set { self.videoBox = newValue.map(_IndirectBox.init) }
    }

    private var videoNoteBox: _IndirectBox<VideoNote>?
    /// *Optional*. Message is a [video
    /// note](https://telegram.org/blog/video-messages-and-telescope), information about the
    /// video message
    public var videoNote: VideoNote? {
        get { self.videoNoteBox?.value }
        set { self.videoNoteBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Message is a voice message, information about the file
    public var voice: Voice?

    /// *Optional*. Caption for the animation, audio, document, paid media, photo, video or
    /// voice
    public var caption: Swift.String?

    /// *Optional*. For messages with a caption, special entities like usernames, URLs, bot
    /// commands, etc. that appear in the caption
    public var captionEntities: [MessageEntity]?

    /// *Optional*. *True*, if the caption must be shown above the message media
    public var showCaptionAboveMedia: Swift.Bool?

    /// *Optional*. *True*, if the message media is covered by a spoiler animation
    public var hasMediaSpoiler: Swift.Bool?

    /// *Optional*. Message is a checklist
    public var checklist: Checklist?

    /// *Optional*. Message is a shared contact, information about the contact
    public var contact: Contact?

    /// *Optional*. Message is a dice with random value
    public var dice: Dice?

    private var gameBox: _IndirectBox<Game>?
    /// *Optional*. Message is a game, information about the game. More about games »
    public var game: Game? {
        get { self.gameBox?.value }
        set { self.gameBox = newValue.map(_IndirectBox.init) }
    }

    private var pollBox: _IndirectBox<Poll>?
    /// *Optional*. Message is a native poll, information about the poll
    public var poll: Poll? {
        get { self.pollBox?.value }
        set { self.pollBox = newValue.map(_IndirectBox.init) }
    }

    private var venueBox: _IndirectBox<Venue>?
    /// *Optional*. Message is a venue, information about the venue. For backward compatibility,
    /// when this field is set, the *location* field will also be set.
    public var venue: Venue? {
        get { self.venueBox?.value }
        set { self.venueBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Message is a shared location, information about the location
    public var location: Location?

    /// *Optional*. New members that were added to the group or supergroup and information about
    /// them (the bot itself may be one of these members)
    public var newChatMembers: [User]?

    private var leftChatMemberBox: _IndirectBox<User>?
    /// *Optional*. A member was removed from the group, information about them (this member may
    /// be the bot itself)
    public var leftChatMember: User? {
        get { self.leftChatMemberBox?.value }
        set { self.leftChatMemberBox = newValue.map(_IndirectBox.init) }
    }

    private var chatOwnerLeftBox: _IndirectBox<ChatOwnerLeft>?
    /// *Optional*. Service message: chat owner has left
    public var chatOwnerLeft: ChatOwnerLeft? {
        get { self.chatOwnerLeftBox?.value }
        set { self.chatOwnerLeftBox = newValue.map(_IndirectBox.init) }
    }

    private var chatOwnerChangedBox: _IndirectBox<ChatOwnerChanged>?
    /// *Optional*. Service message: chat owner has changed
    public var chatOwnerChanged: ChatOwnerChanged? {
        get { self.chatOwnerChangedBox?.value }
        set { self.chatOwnerChangedBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. A chat title was changed to this value
    public var newChatTitle: Swift.String?

    /// *Optional*. A chat photo was change to this value
    public var newChatPhoto: [PhotoSize]?

    /// *Optional*. Service message: the chat photo was deleted
    public var deleteChatPhoto: Swift.Bool?

    /// *Optional*. Service message: the group has been created
    public var groupChatCreated: Swift.Bool?

    /// *Optional*. Service message: the supergroup has been created. This field can't be
    /// received in a message coming through updates, because bot can't be a member of a
    /// supergroup when it is created. It can only be found in reply_to_message if someone
    /// replies to a very first message in a directly created supergroup.
    public var supergroupChatCreated: Swift.Bool?

    /// *Optional*. Service message: the channel has been created. This field can't be received
    /// in a message coming through updates, because bot can't be a member of a channel when it
    /// is created. It can only be found in reply_to_message if someone replies to a very first
    /// message in a channel.
    public var channelChatCreated: Swift.Bool?

    /// *Optional*. Service message: auto-delete timer settings changed in the chat
    public var messageAutoDeleteTimerChanged: MessageAutoDeleteTimerChanged?

    /// *Optional*. The group has been migrated to a supergroup with the specified identifier.
    /// This number may have more than 32 significant bits and some programming languages may
    /// have difficulty/silent defects in interpreting it. But it has at most 52 significant
    /// bits, so a signed 64-bit integer or double-precision float type are safe for storing
    /// this identifier.
    public var migrateToChatId: Swift.Int64?

    /// *Optional*. The supergroup has been migrated from a group with the specified identifier.
    /// This number may have more than 32 significant bits and some programming languages may
    /// have difficulty/silent defects in interpreting it. But it has at most 52 significant
    /// bits, so a signed 64-bit integer or double-precision float type are safe for storing
    /// this identifier.
    public var migrateFromChatId: Swift.Int64?

    /// *Optional*. Specified message was pinned. Note that the ``Message`` object in this field
    /// will not contain further *reply_to_message* fields even if it itself is a reply.
    public var pinnedMessage: MaybeInaccessibleMessage?

    /// *Optional*. Message is an invoice for a `payment`, information about the invoice. More
    /// about payments »
    public var invoice: Invoice?

    private var successfulPaymentBox: _IndirectBox<SuccessfulPayment>?
    /// *Optional*. Message is a service message about a successful payment, information about
    /// the payment. More about payments »
    public var successfulPayment: SuccessfulPayment? {
        get { self.successfulPaymentBox?.value }
        set { self.successfulPaymentBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Message is a service message about a refunded payment, information about the
    /// payment. More about payments »
    public var refundedPayment: RefundedPayment?

    /// *Optional*. Service message: users were shared with the bot
    public var usersShared: UsersShared?

    /// *Optional*. Service message: a chat was shared with the bot
    public var chatShared: ChatShared?

    private var giftBox: _IndirectBox<GiftInfo>?
    /// *Optional*. Service message: a regular gift was sent or received
    public var gift: GiftInfo? {
        get { self.giftBox?.value }
        set { self.giftBox = newValue.map(_IndirectBox.init) }
    }

    private var uniqueGiftBox: _IndirectBox<UniqueGiftInfo>?
    /// *Optional*. Service message: a unique gift was sent or received
    public var uniqueGift: UniqueGiftInfo? {
        get { self.uniqueGiftBox?.value }
        set { self.uniqueGiftBox = newValue.map(_IndirectBox.init) }
    }

    private var giftUpgradeSentBox: _IndirectBox<GiftInfo>?
    /// *Optional*. Service message: upgrade of a gift was purchased after the gift was sent
    public var giftUpgradeSent: GiftInfo? {
        get { self.giftUpgradeSentBox?.value }
        set { self.giftUpgradeSentBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. The domain name of the website on which the user has logged in. More about
    /// Telegram Login »
    public var connectedWebsite: Swift.String?

    /// *Optional*. Service message: the user allowed the bot to write messages after adding it
    /// to the attachment or side menu, launching a Web App from a link, or accepting an
    /// explicit request from a Web App sent by the method requestWriteAccess
    public var writeAccessAllowed: WriteAccessAllowed?

    /// *Optional*. Telegram Passport data
    public var passportData: PassportData?

    private var proximityAlertTriggeredBox: _IndirectBox<ProximityAlertTriggered>?
    /// *Optional*. Service message: a user in the chat triggered another user's proximity alert
    /// while sharing Live Location
    public var proximityAlertTriggered: ProximityAlertTriggered? {
        get { self.proximityAlertTriggeredBox?.value }
        set { self.proximityAlertTriggeredBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Service message: user boosted the chat
    public var boostAdded: ChatBoostAdded?

    private var chatBackgroundSetBox: _IndirectBox<ChatBackground>?
    /// *Optional*. Service message: chat background set
    public var chatBackgroundSet: ChatBackground? {
        get { self.chatBackgroundSetBox?.value }
        set { self.chatBackgroundSetBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Service message: some tasks in a checklist were marked as done or not done
    public var checklistTasksDone: ChecklistTasksDone?

    /// *Optional*. Service message: tasks were added to a checklist
    public var checklistTasksAdded: ChecklistTasksAdded?

    /// *Optional*. Service message: chat or bot added to a ``Community``
    public var communityChatAdded: CommunityChatAdded?

    /// *Optional*. Service message: chat was joined by a user from a ``Community``
    public var communityChatJoined: CommunityChatJoined?

    /// *Optional*. Service message: chat or bot removed from a ``Community``
    public var communityChatRemoved: CommunityChatRemoved?

    /// *Optional*. Service message: the price for paid messages in the corresponding direct
    /// messages chat of a channel has changed
    public var directMessagePriceChanged: DirectMessagePriceChanged?

    /// *Optional*. Service message: forum topic created
    public var forumTopicCreated: ForumTopicCreated?

    /// *Optional*. Service message: forum topic edited
    public var forumTopicEdited: ForumTopicEdited?

    /// *Optional*. Service message: forum topic closed
    public var forumTopicClosed: ForumTopicClosed?

    /// *Optional*. Service message: forum topic reopened
    public var forumTopicReopened: ForumTopicReopened?

    /// *Optional*. Service message: the 'General' forum topic hidden
    public var generalForumTopicHidden: GeneralForumTopicHidden?

    /// *Optional*. Service message: the 'General' forum topic unhidden
    public var generalForumTopicUnhidden: GeneralForumTopicUnhidden?

    /// *Optional*. Service message: a scheduled giveaway was created
    public var giveawayCreated: GiveawayCreated?

    /// *Optional*. The message is a scheduled giveaway message
    public var giveaway: Giveaway?

    private var giveawayWinnersBox: _IndirectBox<GiveawayWinners>?
    /// *Optional*. A giveaway with public winners was completed
    public var giveawayWinners: GiveawayWinners? {
        get { self.giveawayWinnersBox?.value }
        set { self.giveawayWinnersBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Service message: a giveaway without public winners was completed
    public var giveawayCompleted: GiveawayCompleted?

    private var managedBotCreatedBox: _IndirectBox<ManagedBotCreated>?
    /// *Optional*. Service message: user created a bot that will be managed by the current bot
    public var managedBotCreated: ManagedBotCreated? {
        get { self.managedBotCreatedBox?.value }
        set { self.managedBotCreatedBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Service message: the price for paid messages has changed in the chat
    public var paidMessagePriceChanged: PaidMessagePriceChanged?

    /// *Optional*. Service message: answer option was added to a poll
    public var pollOptionAdded: PollOptionAdded?

    /// *Optional*. Service message: answer option was deleted from a poll
    public var pollOptionDeleted: PollOptionDeleted?

    /// *Optional*. Service message: a suggested post was approved
    public var suggestedPostApproved: SuggestedPostApproved?

    /// *Optional*. Service message: approval of a suggested post has failed
    public var suggestedPostApprovalFailed: SuggestedPostApprovalFailed?

    /// *Optional*. Service message: a suggested post was declined
    public var suggestedPostDeclined: SuggestedPostDeclined?

    /// *Optional*. Service message: payment for a suggested post was received
    public var suggestedPostPaid: SuggestedPostPaid?

    /// *Optional*. Service message: payment for a suggested post was refunded
    public var suggestedPostRefunded: SuggestedPostRefunded?

    /// *Optional*. Service message: video chat scheduled
    public var videoChatScheduled: VideoChatScheduled?

    /// *Optional*. Service message: video chat started
    public var videoChatStarted: VideoChatStarted?

    /// *Optional*. Service message: video chat ended
    public var videoChatEnded: VideoChatEnded?

    /// *Optional*. Service message: new participants invited to a video chat
    public var videoChatParticipantsInvited: VideoChatParticipantsInvited?

    /// *Optional*. Service message: data sent by a Web App
    public var webAppData: WebAppData?

    /// *Optional*. Inline keyboard attached to the message. `login_url` buttons are represented
    /// as ordinary `url` buttons.
    public var replyMarkup: InlineKeyboardMarkup?

    public init(
        messageId: Swift.Int64,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopic: DirectMessagesTopic? = nil,
        from: User? = nil,
        senderChat: Chat? = nil,
        senderBoostCount: Swift.Int64? = nil,
        senderBusinessBot: User? = nil,
        senderTag: Swift.String? = nil,
        receiverUser: User? = nil,
        ephemeralMessageId: Swift.Int64? = nil,
        date: Swift.Int64,
        guestQueryId: Swift.String? = nil,
        businessConnectionId: Swift.String? = nil,
        chat: Chat,
        forwardOrigin: MessageOrigin? = nil,
        isTopicMessage: Swift.Bool? = nil,
        isAutomaticForward: Swift.Bool? = nil,
        replyToMessage: Message? = nil,
        externalReply: ExternalReplyInfo? = nil,
        quote: TextQuote? = nil,
        replyToStory: Story? = nil,
        replyToChecklistTaskId: Swift.Int64? = nil,
        replyToPollOptionId: Swift.String? = nil,
        viaBot: User? = nil,
        guestBotCallerUser: User? = nil,
        guestBotCallerChat: Chat? = nil,
        editDate: Swift.Int64? = nil,
        hasProtectedContent: Swift.Bool? = nil,
        isFromOffline: Swift.Bool? = nil,
        isPaidPost: Swift.Bool? = nil,
        mediaGroupId: Swift.String? = nil,
        authorSignature: Swift.String? = nil,
        paidStarCount: Swift.Int64? = nil,
        text: Swift.String? = nil,
        entities: [MessageEntity]? = nil,
        linkPreviewOptions: LinkPreviewOptions? = nil,
        suggestedPostInfo: SuggestedPostInfo? = nil,
        effectId: Swift.String? = nil,
        richMessage: RichMessage? = nil,
        animation: Animation? = nil,
        audio: Audio? = nil,
        document: Document? = nil,
        livePhoto: LivePhoto? = nil,
        paidMedia: PaidMediaInfo? = nil,
        photo: [PhotoSize]? = nil,
        sticker: Sticker? = nil,
        story: Story? = nil,
        video: Video? = nil,
        videoNote: VideoNote? = nil,
        voice: Voice? = nil,
        caption: Swift.String? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Swift.Bool? = nil,
        hasMediaSpoiler: Swift.Bool? = nil,
        checklist: Checklist? = nil,
        contact: Contact? = nil,
        dice: Dice? = nil,
        game: Game? = nil,
        poll: Poll? = nil,
        venue: Venue? = nil,
        location: Location? = nil,
        newChatMembers: [User]? = nil,
        leftChatMember: User? = nil,
        chatOwnerLeft: ChatOwnerLeft? = nil,
        chatOwnerChanged: ChatOwnerChanged? = nil,
        newChatTitle: Swift.String? = nil,
        newChatPhoto: [PhotoSize]? = nil,
        deleteChatPhoto: Swift.Bool? = nil,
        groupChatCreated: Swift.Bool? = nil,
        supergroupChatCreated: Swift.Bool? = nil,
        channelChatCreated: Swift.Bool? = nil,
        messageAutoDeleteTimerChanged: MessageAutoDeleteTimerChanged? = nil,
        migrateToChatId: Swift.Int64? = nil,
        migrateFromChatId: Swift.Int64? = nil,
        pinnedMessage: MaybeInaccessibleMessage? = nil,
        invoice: Invoice? = nil,
        successfulPayment: SuccessfulPayment? = nil,
        refundedPayment: RefundedPayment? = nil,
        usersShared: UsersShared? = nil,
        chatShared: ChatShared? = nil,
        gift: GiftInfo? = nil,
        uniqueGift: UniqueGiftInfo? = nil,
        giftUpgradeSent: GiftInfo? = nil,
        connectedWebsite: Swift.String? = nil,
        writeAccessAllowed: WriteAccessAllowed? = nil,
        passportData: PassportData? = nil,
        proximityAlertTriggered: ProximityAlertTriggered? = nil,
        boostAdded: ChatBoostAdded? = nil,
        chatBackgroundSet: ChatBackground? = nil,
        checklistTasksDone: ChecklistTasksDone? = nil,
        checklistTasksAdded: ChecklistTasksAdded? = nil,
        communityChatAdded: CommunityChatAdded? = nil,
        communityChatJoined: CommunityChatJoined? = nil,
        communityChatRemoved: CommunityChatRemoved? = nil,
        directMessagePriceChanged: DirectMessagePriceChanged? = nil,
        forumTopicCreated: ForumTopicCreated? = nil,
        forumTopicEdited: ForumTopicEdited? = nil,
        forumTopicClosed: ForumTopicClosed? = nil,
        forumTopicReopened: ForumTopicReopened? = nil,
        generalForumTopicHidden: GeneralForumTopicHidden? = nil,
        generalForumTopicUnhidden: GeneralForumTopicUnhidden? = nil,
        giveawayCreated: GiveawayCreated? = nil,
        giveaway: Giveaway? = nil,
        giveawayWinners: GiveawayWinners? = nil,
        giveawayCompleted: GiveawayCompleted? = nil,
        managedBotCreated: ManagedBotCreated? = nil,
        paidMessagePriceChanged: PaidMessagePriceChanged? = nil,
        pollOptionAdded: PollOptionAdded? = nil,
        pollOptionDeleted: PollOptionDeleted? = nil,
        suggestedPostApproved: SuggestedPostApproved? = nil,
        suggestedPostApprovalFailed: SuggestedPostApprovalFailed? = nil,
        suggestedPostDeclined: SuggestedPostDeclined? = nil,
        suggestedPostPaid: SuggestedPostPaid? = nil,
        suggestedPostRefunded: SuggestedPostRefunded? = nil,
        videoChatScheduled: VideoChatScheduled? = nil,
        videoChatStarted: VideoChatStarted? = nil,
        videoChatEnded: VideoChatEnded? = nil,
        videoChatParticipantsInvited: VideoChatParticipantsInvited? = nil,
        webAppData: WebAppData? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) {
        self.messageId = messageId
        self.messageThreadId = messageThreadId
        self.directMessagesTopicBox = directMessagesTopic.map(_IndirectBox.init)
        self.fromBox = from.map(_IndirectBox.init)
        self.senderChatBox = senderChat.map(_IndirectBox.init)
        self.senderBoostCount = senderBoostCount
        self.senderBusinessBotBox = senderBusinessBot.map(_IndirectBox.init)
        self.senderTag = senderTag
        self.receiverUserBox = receiverUser.map(_IndirectBox.init)
        self.ephemeralMessageId = ephemeralMessageId
        self.date = date
        self.guestQueryId = guestQueryId
        self.businessConnectionId = businessConnectionId
        self.chatBox = _IndirectBox(chat)
        self.forwardOriginBox = forwardOrigin.map(_IndirectBox.init)
        self.isTopicMessage = isTopicMessage
        self.isAutomaticForward = isAutomaticForward
        self.replyToMessageBox = replyToMessage.map(_IndirectBox.init)
        self.externalReplyBox = externalReply.map(_IndirectBox.init)
        self.quote = quote
        self.replyToStoryBox = replyToStory.map(_IndirectBox.init)
        self.replyToChecklistTaskId = replyToChecklistTaskId
        self.replyToPollOptionId = replyToPollOptionId
        self.viaBotBox = viaBot.map(_IndirectBox.init)
        self.guestBotCallerUserBox = guestBotCallerUser.map(_IndirectBox.init)
        self.guestBotCallerChatBox = guestBotCallerChat.map(_IndirectBox.init)
        self.editDate = editDate
        self.hasProtectedContent = hasProtectedContent
        self.isFromOffline = isFromOffline
        self.isPaidPost = isPaidPost
        self.mediaGroupId = mediaGroupId
        self.authorSignature = authorSignature
        self.paidStarCount = paidStarCount
        self.text = text
        self.entities = entities
        self.linkPreviewOptions = linkPreviewOptions
        self.suggestedPostInfo = suggestedPostInfo
        self.effectId = effectId
        self.richMessage = richMessage
        self.animationBox = animation.map(_IndirectBox.init)
        self.audioBox = audio.map(_IndirectBox.init)
        self.documentBox = document.map(_IndirectBox.init)
        self.livePhoto = livePhoto
        self.paidMedia = paidMedia
        self.photo = photo
        self.stickerBox = sticker.map(_IndirectBox.init)
        self.storyBox = story.map(_IndirectBox.init)
        self.videoBox = video.map(_IndirectBox.init)
        self.videoNoteBox = videoNote.map(_IndirectBox.init)
        self.voice = voice
        self.caption = caption
        self.captionEntities = captionEntities
        self.showCaptionAboveMedia = showCaptionAboveMedia
        self.hasMediaSpoiler = hasMediaSpoiler
        self.checklist = checklist
        self.contact = contact
        self.dice = dice
        self.gameBox = game.map(_IndirectBox.init)
        self.pollBox = poll.map(_IndirectBox.init)
        self.venueBox = venue.map(_IndirectBox.init)
        self.location = location
        self.newChatMembers = newChatMembers
        self.leftChatMemberBox = leftChatMember.map(_IndirectBox.init)
        self.chatOwnerLeftBox = chatOwnerLeft.map(_IndirectBox.init)
        self.chatOwnerChangedBox = chatOwnerChanged.map(_IndirectBox.init)
        self.newChatTitle = newChatTitle
        self.newChatPhoto = newChatPhoto
        self.deleteChatPhoto = deleteChatPhoto
        self.groupChatCreated = groupChatCreated
        self.supergroupChatCreated = supergroupChatCreated
        self.channelChatCreated = channelChatCreated
        self.messageAutoDeleteTimerChanged = messageAutoDeleteTimerChanged
        self.migrateToChatId = migrateToChatId
        self.migrateFromChatId = migrateFromChatId
        self.pinnedMessage = pinnedMessage
        self.invoice = invoice
        self.successfulPaymentBox = successfulPayment.map(_IndirectBox.init)
        self.refundedPayment = refundedPayment
        self.usersShared = usersShared
        self.chatShared = chatShared
        self.giftBox = gift.map(_IndirectBox.init)
        self.uniqueGiftBox = uniqueGift.map(_IndirectBox.init)
        self.giftUpgradeSentBox = giftUpgradeSent.map(_IndirectBox.init)
        self.connectedWebsite = connectedWebsite
        self.writeAccessAllowed = writeAccessAllowed
        self.passportData = passportData
        self.proximityAlertTriggeredBox = proximityAlertTriggered.map(_IndirectBox.init)
        self.boostAdded = boostAdded
        self.chatBackgroundSetBox = chatBackgroundSet.map(_IndirectBox.init)
        self.checklistTasksDone = checklistTasksDone
        self.checklistTasksAdded = checklistTasksAdded
        self.communityChatAdded = communityChatAdded
        self.communityChatJoined = communityChatJoined
        self.communityChatRemoved = communityChatRemoved
        self.directMessagePriceChanged = directMessagePriceChanged
        self.forumTopicCreated = forumTopicCreated
        self.forumTopicEdited = forumTopicEdited
        self.forumTopicClosed = forumTopicClosed
        self.forumTopicReopened = forumTopicReopened
        self.generalForumTopicHidden = generalForumTopicHidden
        self.generalForumTopicUnhidden = generalForumTopicUnhidden
        self.giveawayCreated = giveawayCreated
        self.giveaway = giveaway
        self.giveawayWinnersBox = giveawayWinners.map(_IndirectBox.init)
        self.giveawayCompleted = giveawayCompleted
        self.managedBotCreatedBox = managedBotCreated.map(_IndirectBox.init)
        self.paidMessagePriceChanged = paidMessagePriceChanged
        self.pollOptionAdded = pollOptionAdded
        self.pollOptionDeleted = pollOptionDeleted
        self.suggestedPostApproved = suggestedPostApproved
        self.suggestedPostApprovalFailed = suggestedPostApprovalFailed
        self.suggestedPostDeclined = suggestedPostDeclined
        self.suggestedPostPaid = suggestedPostPaid
        self.suggestedPostRefunded = suggestedPostRefunded
        self.videoChatScheduled = videoChatScheduled
        self.videoChatStarted = videoChatStarted
        self.videoChatEnded = videoChatEnded
        self.videoChatParticipantsInvited = videoChatParticipantsInvited
        self.webAppData = webAppData
        self.replyMarkup = replyMarkup
    }

    public enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case messageThreadId = "message_thread_id"
        case directMessagesTopicBox = "direct_messages_topic"
        case fromBox = "from"
        case senderChatBox = "sender_chat"
        case senderBoostCount = "sender_boost_count"
        case senderBusinessBotBox = "sender_business_bot"
        case senderTag = "sender_tag"
        case receiverUserBox = "receiver_user"
        case ephemeralMessageId = "ephemeral_message_id"
        case date
        case guestQueryId = "guest_query_id"
        case businessConnectionId = "business_connection_id"
        case chatBox = "chat"
        case forwardOriginBox = "forward_origin"
        case isTopicMessage = "is_topic_message"
        case isAutomaticForward = "is_automatic_forward"
        case replyToMessageBox = "reply_to_message"
        case externalReplyBox = "external_reply"
        case quote
        case replyToStoryBox = "reply_to_story"
        case replyToChecklistTaskId = "reply_to_checklist_task_id"
        case replyToPollOptionId = "reply_to_poll_option_id"
        case viaBotBox = "via_bot"
        case guestBotCallerUserBox = "guest_bot_caller_user"
        case guestBotCallerChatBox = "guest_bot_caller_chat"
        case editDate = "edit_date"
        case hasProtectedContent = "has_protected_content"
        case isFromOffline = "is_from_offline"
        case isPaidPost = "is_paid_post"
        case mediaGroupId = "media_group_id"
        case authorSignature = "author_signature"
        case paidStarCount = "paid_star_count"
        case text
        case entities
        case linkPreviewOptions = "link_preview_options"
        case suggestedPostInfo = "suggested_post_info"
        case effectId = "effect_id"
        case richMessage = "rich_message"
        case animationBox = "animation"
        case audioBox = "audio"
        case documentBox = "document"
        case livePhoto = "live_photo"
        case paidMedia = "paid_media"
        case photo
        case stickerBox = "sticker"
        case storyBox = "story"
        case videoBox = "video"
        case videoNoteBox = "video_note"
        case voice
        case caption
        case captionEntities = "caption_entities"
        case showCaptionAboveMedia = "show_caption_above_media"
        case hasMediaSpoiler = "has_media_spoiler"
        case checklist
        case contact
        case dice
        case gameBox = "game"
        case pollBox = "poll"
        case venueBox = "venue"
        case location
        case newChatMembers = "new_chat_members"
        case leftChatMemberBox = "left_chat_member"
        case chatOwnerLeftBox = "chat_owner_left"
        case chatOwnerChangedBox = "chat_owner_changed"
        case newChatTitle = "new_chat_title"
        case newChatPhoto = "new_chat_photo"
        case deleteChatPhoto = "delete_chat_photo"
        case groupChatCreated = "group_chat_created"
        case supergroupChatCreated = "supergroup_chat_created"
        case channelChatCreated = "channel_chat_created"
        case messageAutoDeleteTimerChanged = "message_auto_delete_timer_changed"
        case migrateToChatId = "migrate_to_chat_id"
        case migrateFromChatId = "migrate_from_chat_id"
        case pinnedMessage = "pinned_message"
        case invoice
        case successfulPaymentBox = "successful_payment"
        case refundedPayment = "refunded_payment"
        case usersShared = "users_shared"
        case chatShared = "chat_shared"
        case giftBox = "gift"
        case uniqueGiftBox = "unique_gift"
        case giftUpgradeSentBox = "gift_upgrade_sent"
        case connectedWebsite = "connected_website"
        case writeAccessAllowed = "write_access_allowed"
        case passportData = "passport_data"
        case proximityAlertTriggeredBox = "proximity_alert_triggered"
        case boostAdded = "boost_added"
        case chatBackgroundSetBox = "chat_background_set"
        case checklistTasksDone = "checklist_tasks_done"
        case checklistTasksAdded = "checklist_tasks_added"
        case communityChatAdded = "community_chat_added"
        case communityChatJoined = "community_chat_joined"
        case communityChatRemoved = "community_chat_removed"
        case directMessagePriceChanged = "direct_message_price_changed"
        case forumTopicCreated = "forum_topic_created"
        case forumTopicEdited = "forum_topic_edited"
        case forumTopicClosed = "forum_topic_closed"
        case forumTopicReopened = "forum_topic_reopened"
        case generalForumTopicHidden = "general_forum_topic_hidden"
        case generalForumTopicUnhidden = "general_forum_topic_unhidden"
        case giveawayCreated = "giveaway_created"
        case giveaway
        case giveawayWinnersBox = "giveaway_winners"
        case giveawayCompleted = "giveaway_completed"
        case managedBotCreatedBox = "managed_bot_created"
        case paidMessagePriceChanged = "paid_message_price_changed"
        case pollOptionAdded = "poll_option_added"
        case pollOptionDeleted = "poll_option_deleted"
        case suggestedPostApproved = "suggested_post_approved"
        case suggestedPostApprovalFailed = "suggested_post_approval_failed"
        case suggestedPostDeclined = "suggested_post_declined"
        case suggestedPostPaid = "suggested_post_paid"
        case suggestedPostRefunded = "suggested_post_refunded"
        case videoChatScheduled = "video_chat_scheduled"
        case videoChatStarted = "video_chat_started"
        case videoChatEnded = "video_chat_ended"
        case videoChatParticipantsInvited = "video_chat_participants_invited"
        case webAppData = "web_app_data"
        case replyMarkup = "reply_markup"
    }
}
