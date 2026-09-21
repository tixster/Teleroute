// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The paid media is a video.
public struct PaidMediaVideo: Codable, Hashable, Sendable {
    /// Type of the paid media, always “video”
    public var type: PaidMediaKind

    private var videoBox: _IndirectBox<Video>
    /// The video
    public var video: Video {
        get { self.videoBox.value }
        set { self.videoBox = _IndirectBox(newValue) }
    }

    public init(
        type: PaidMediaKind = .video,
        video: Video
    ) {
        self.type = type
        self.videoBox = _IndirectBox(video)
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case videoBox = "video"
    }
}
