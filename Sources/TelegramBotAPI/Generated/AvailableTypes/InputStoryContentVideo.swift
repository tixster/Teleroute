// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a video to post as a story.
public struct InputStoryContentVideo: Codable, Hashable, Sendable {
    /// Type of the content, must be *video*
    public var type: InputStoryContentKind

    /// The video to post as a story. The video must be of the size 720x1280, streamable,
    /// encoded with H.265 codec, with key frames added each second in the MPEG4 format, and
    /// must not exceed 30 MB. The video can't be reused and can only be uploaded as a new file,
    /// so you can pass “attach://<file_attach_name>” if the video was uploaded using
    /// multipart/form-data under <file_attach_name>. More information on Sending Files »
    public var video: Swift.String

    /// *Optional*. Precise duration of the video in seconds; 0-60
    public var duration: Swift.Double?

    /// *Optional*. Timestamp in seconds of the frame that will be used as the static cover for
    /// the story. Defaults to 0.0.
    public var coverFrameTimestamp: Swift.Double?

    /// *Optional*. Pass *True* if the video has no sound
    public var isAnimation: Swift.Bool?

    public init(
        type: InputStoryContentKind = .video,
        video: Swift.String,
        duration: Swift.Double? = nil,
        coverFrameTimestamp: Swift.Double? = nil,
        isAnimation: Swift.Bool? = nil
    ) {
        self.type = type
        self.video = video
        self.duration = duration
        self.coverFrameTimestamp = coverFrameTimestamp
        self.isAnimation = isAnimation
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case video
        case duration
        case coverFrameTimestamp = "cover_frame_timestamp"
        case isAnimation = "is_animation"
    }
}
