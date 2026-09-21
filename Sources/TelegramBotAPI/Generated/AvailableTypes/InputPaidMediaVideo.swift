// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The paid media to send is a video.
public struct InputPaidMediaVideo: Codable, Hashable, Sendable {
    /// Type of the media, must be *video*
    public var type: InputPaidMediaKind

    /// File to send. Pass a file_id to send a file that exists on the Telegram servers
    /// (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass
    /// “attach://<file_attach_name>” to upload a new one using multipart/form-data under
    /// <file_attach_name> name. More information on Sending Files »
    public var media: Swift.String

    /// *Optional*. Thumbnail of the file sent; can be ignored if thumbnail generation for the
    /// file is supported server-side. The thumbnail should be in JPEG format and less than 200
    /// kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is
    /// not uploaded using multipart/form-data. Thumbnails can't be reused and can be only
    /// uploaded as a new file, so you can pass “attach://<file_attach_name>” if the thumbnail
    /// was uploaded using multipart/form-data under <file_attach_name>. More information on
    /// Sending Files »
    public var thumbnail: Swift.String?

    /// *Optional*. Cover for the video in the message. Pass a file_id to send a file that
    /// exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a
    /// file from the Internet, or pass “attach://<file_attach_name>” to upload a new one using
    /// multipart/form-data under <file_attach_name> name. More information on Sending Files »
    public var cover: Swift.String?

    /// *Optional*. Start timestamp for the video in the message
    public var startTimestamp: Swift.Int64?

    /// *Optional*. Video width
    public var width: Swift.Int64?

    /// *Optional*. Video height
    public var height: Swift.Int64?

    /// *Optional*. Video duration in seconds
    public var duration: Swift.Int64?

    /// *Optional*. Pass *True* if the uploaded video is suitable for streaming
    public var supportsStreaming: Swift.Bool?

    public init(
        type: InputPaidMediaKind = .video,
        media: Swift.String,
        thumbnail: Swift.String? = nil,
        cover: Swift.String? = nil,
        startTimestamp: Swift.Int64? = nil,
        width: Swift.Int64? = nil,
        height: Swift.Int64? = nil,
        duration: Swift.Int64? = nil,
        supportsStreaming: Swift.Bool? = nil
    ) {
        self.type = type
        self.media = media
        self.thumbnail = thumbnail
        self.cover = cover
        self.startTimestamp = startTimestamp
        self.width = width
        self.height = height
        self.duration = duration
        self.supportsStreaming = supportsStreaming
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case media
        case thumbnail
        case cover
        case startTimestamp = "start_timestamp"
        case width
        case height
        case duration
        case supportsStreaming = "supports_streaming"
    }
}
