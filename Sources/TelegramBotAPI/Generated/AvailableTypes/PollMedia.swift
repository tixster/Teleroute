// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// At most **one** of the optional fields can be present in any given object.
public struct PollMedia: Codable, Hashable, Sendable {
    private var animationBox: _IndirectBox<Animation>?
    /// *Optional*. Media is an animation, information about the animation
    public var animation: Animation? {
        get { self.animationBox?.value }
        set { self.animationBox = newValue.map(_IndirectBox.init) }
    }

    private var audioBox: _IndirectBox<Audio>?
    /// *Optional*. Media is an audio file, information about the file; currently, can't be
    /// received in a poll option
    public var audio: Audio? {
        get { self.audioBox?.value }
        set { self.audioBox = newValue.map(_IndirectBox.init) }
    }

    private var documentBox: _IndirectBox<Document>?
    /// *Optional*. Media is a general file, information about the file; currently, can't be
    /// received in a poll option
    public var document: Document? {
        get { self.documentBox?.value }
        set { self.documentBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. The HTTP link attached to the poll option
    public var link: Link?

    /// *Optional*. Media is a live photo, information about the live photo
    public var livePhoto: LivePhoto?

    /// *Optional*. Media is a shared location, information about the location
    public var location: Location?

    /// *Optional*. Media is a photo, available sizes of the photo
    public var photo: [PhotoSize]?

    private var stickerBox: _IndirectBox<Sticker>?
    /// *Optional*. Media is a sticker, information about the sticker; currently, for poll
    /// options only
    public var sticker: Sticker? {
        get { self.stickerBox?.value }
        set { self.stickerBox = newValue.map(_IndirectBox.init) }
    }

    private var venueBox: _IndirectBox<Venue>?
    /// *Optional*. Media is a venue, information about the venue
    public var venue: Venue? {
        get { self.venueBox?.value }
        set { self.venueBox = newValue.map(_IndirectBox.init) }
    }

    private var videoBox: _IndirectBox<Video>?
    /// *Optional*. Media is a video, information about the video
    public var video: Video? {
        get { self.videoBox?.value }
        set { self.videoBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        animation: Animation? = nil,
        audio: Audio? = nil,
        document: Document? = nil,
        link: Link? = nil,
        livePhoto: LivePhoto? = nil,
        location: Location? = nil,
        photo: [PhotoSize]? = nil,
        sticker: Sticker? = nil,
        venue: Venue? = nil,
        video: Video? = nil
    ) {
        self.animationBox = animation.map(_IndirectBox.init)
        self.audioBox = audio.map(_IndirectBox.init)
        self.documentBox = document.map(_IndirectBox.init)
        self.link = link
        self.livePhoto = livePhoto
        self.location = location
        self.photo = photo
        self.stickerBox = sticker.map(_IndirectBox.init)
        self.venueBox = venue.map(_IndirectBox.init)
        self.videoBox = video.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case animationBox = "animation"
        case audioBox = "audio"
        case documentBox = "document"
        case link
        case livePhoto = "live_photo"
        case location
        case photo
        case stickerBox = "sticker"
        case venueBox = "venue"
        case videoBox = "video"
    }
}
