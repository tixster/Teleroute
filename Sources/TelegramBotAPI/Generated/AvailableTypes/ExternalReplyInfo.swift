// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains information about a message that is being replied to, which may come
/// from another chat or forum topic.
public struct ExternalReplyInfo: Codable, Hashable, Sendable {
    private var originBox: _IndirectBox<MessageOrigin>
    /// Origin of the message replied to by the given message
    public var origin: MessageOrigin {
        get { self.originBox.value }
        set { self.originBox = _IndirectBox(newValue) }
    }

    private var chatBox: _IndirectBox<Chat>?
    /// *Optional*. Chat the original message belongs to. Available only if the chat is a
    /// supergroup or a channel.
    public var chat: Chat? {
        get { self.chatBox?.value }
        set { self.chatBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Unique message identifier inside the original chat. Available only if the
    /// original chat is a supergroup or a channel.
    public var messageId: Swift.Int64?

    /// *Optional*. Options used for link preview generation for the original message, if it is
    /// a text message
    public var linkPreviewOptions: LinkPreviewOptions?

    private var animationBox: _IndirectBox<Animation>?
    /// *Optional*. Message is an animation, information about the animation
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

    /// *Optional*. Message is a live photo, information about the live photo
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

    /// *Optional*. Message is a scheduled giveaway, information about the giveaway
    public var giveaway: Giveaway?

    private var giveawayWinnersBox: _IndirectBox<GiveawayWinners>?
    /// *Optional*. A giveaway with public winners was completed
    public var giveawayWinners: GiveawayWinners? {
        get { self.giveawayWinnersBox?.value }
        set { self.giveawayWinnersBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Message is an invoice for a `payment`, information about the invoice. More
    /// about payments »
    public var invoice: Invoice?

    /// *Optional*. Message is a shared location, information about the location
    public var location: Location?

    private var pollBox: _IndirectBox<Poll>?
    /// *Optional*. Message is a native poll, information about the poll
    public var poll: Poll? {
        get { self.pollBox?.value }
        set { self.pollBox = newValue.map(_IndirectBox.init) }
    }

    private var venueBox: _IndirectBox<Venue>?
    /// *Optional*. Message is a venue, information about the venue
    public var venue: Venue? {
        get { self.venueBox?.value }
        set { self.venueBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        origin: MessageOrigin,
        chat: Chat? = nil,
        messageId: Swift.Int64? = nil,
        linkPreviewOptions: LinkPreviewOptions? = nil,
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
        hasMediaSpoiler: Swift.Bool? = nil,
        checklist: Checklist? = nil,
        contact: Contact? = nil,
        dice: Dice? = nil,
        game: Game? = nil,
        giveaway: Giveaway? = nil,
        giveawayWinners: GiveawayWinners? = nil,
        invoice: Invoice? = nil,
        location: Location? = nil,
        poll: Poll? = nil,
        venue: Venue? = nil
    ) {
        self.originBox = _IndirectBox(origin)
        self.chatBox = chat.map(_IndirectBox.init)
        self.messageId = messageId
        self.linkPreviewOptions = linkPreviewOptions
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
        self.hasMediaSpoiler = hasMediaSpoiler
        self.checklist = checklist
        self.contact = contact
        self.dice = dice
        self.gameBox = game.map(_IndirectBox.init)
        self.giveaway = giveaway
        self.giveawayWinnersBox = giveawayWinners.map(_IndirectBox.init)
        self.invoice = invoice
        self.location = location
        self.pollBox = poll.map(_IndirectBox.init)
        self.venueBox = venue.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case originBox = "origin"
        case chatBox = "chat"
        case messageId = "message_id"
        case linkPreviewOptions = "link_preview_options"
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
        case hasMediaSpoiler = "has_media_spoiler"
        case checklist
        case contact
        case dice
        case gameBox = "game"
        case giveaway
        case giveawayWinnersBox = "giveaway_winners"
        case invoice
        case location
        case pollBox = "poll"
        case venueBox = "venue"
    }
}
