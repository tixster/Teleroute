// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A block with a video, corresponding to the HTML tag `<video>`.
public struct RichBlockVideo: Codable, Hashable, Sendable {
    /// Type of the block, always “video”
    public var type: RichBlockKind

    private var videoBox: _IndirectBox<Video>
    /// The video
    public var video: Video {
        get { self.videoBox.value }
        set { self.videoBox = _IndirectBox(newValue) }
    }

    /// *Optional*. *True*, if the media preview is covered by a spoiler animation
    public var hasSpoiler: Swift.Bool?

    /// *Optional*. Caption of the block
    public var caption: RichBlockCaption?

    public init(
        type: RichBlockKind = .video,
        video: Video,
        hasSpoiler: Swift.Bool? = nil,
        caption: RichBlockCaption? = nil
    ) {
        self.type = type
        self.videoBox = _IndirectBox(video)
        self.hasSpoiler = hasSpoiler
        self.caption = caption
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case videoBox = "video"
        case hasSpoiler = "has_spoiler"
        case caption
    }
}
