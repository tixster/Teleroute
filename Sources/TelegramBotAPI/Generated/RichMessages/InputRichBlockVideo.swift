// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A block with a video, corresponding to the HTML tag `<video>`.
public struct InputRichBlockVideo: Codable, Hashable, Sendable {
    /// Type of the block, always “video”
    public var type: RichBlockKind

    private var videoBox: _IndirectBox<InputMediaVideo>
    /// The video. Caption is ignored.
    public var video: InputMediaVideo {
        get { self.videoBox.value }
        set { self.videoBox = _IndirectBox(newValue) }
    }

    /// *Optional*. Caption of the block
    public var caption: RichBlockCaption?

    public init(
        type: RichBlockKind = .video,
        video: InputMediaVideo,
        caption: RichBlockCaption? = nil
    ) {
        self.type = type
        self.videoBox = _IndirectBox(video)
        self.caption = caption
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case videoBox = "video"
        case caption
    }
}
