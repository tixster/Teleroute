// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a video to be sent.
public struct InputMediaVideo: Codable, Hashable, Sendable {
    /// Type of the media, must be *video*
    public var type: InputPollMediaKind

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

    /// *Optional*. Caption of the video to be sent, 0-1024 characters after entities parsing
    public var caption: Swift.String?

    /// *Optional*. Mode for parsing entities in the video caption. See formatting options for
    /// more details.
    public var parseMode: Swift.String?

    /// *Optional*. List of special entities that appear in the caption, which can be specified
    /// instead of *parse_mode*
    public var captionEntities: [MessageEntity]?

    /// *Optional*. Pass *True* if the caption must be shown above the message media
    public var showCaptionAboveMedia: Swift.Bool?

    /// *Optional*. Video width
    public var width: Swift.Int64?

    /// *Optional*. Video height
    public var height: Swift.Int64?

    /// *Optional*. Video duration in seconds
    public var duration: Swift.Int64?

    /// *Optional*. Pass *True* if the uploaded video is suitable for streaming
    public var supportsStreaming: Swift.Bool?

    /// *Optional*. Pass *True* if the video needs to be covered with a spoiler animation
    public var hasSpoiler: Swift.Bool?

    public init(
        type: InputPollMediaKind = .video,
        media: Swift.String,
        thumbnail: Swift.String? = nil,
        cover: Swift.String? = nil,
        startTimestamp: Swift.Int64? = nil,
        caption: Swift.String? = nil,
        parseMode: Swift.String? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Swift.Bool? = nil,
        width: Swift.Int64? = nil,
        height: Swift.Int64? = nil,
        duration: Swift.Int64? = nil,
        supportsStreaming: Swift.Bool? = nil,
        hasSpoiler: Swift.Bool? = nil
    ) {
        self.type = type
        self.media = media
        self.thumbnail = thumbnail
        self.cover = cover
        self.startTimestamp = startTimestamp
        self.caption = caption
        self.parseMode = parseMode
        self.captionEntities = captionEntities
        self.showCaptionAboveMedia = showCaptionAboveMedia
        self.width = width
        self.height = height
        self.duration = duration
        self.supportsStreaming = supportsStreaming
        self.hasSpoiler = hasSpoiler
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case media
        case thumbnail
        case cover
        case startTimestamp = "start_timestamp"
        case caption
        case parseMode = "parse_mode"
        case captionEntities = "caption_entities"
        case showCaptionAboveMedia = "show_caption_above_media"
        case width
        case height
        case duration
        case supportsStreaming = "supports_streaming"
        case hasSpoiler = "has_spoiler"
    }
}
