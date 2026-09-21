// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a video file.
public struct Video: Codable, Hashable, Sendable {
    /// Identifier for this file, which can be used to download or reuse the file
    public var fileId: Swift.String

    /// Unique identifier for this file, which is supposed to be the same over time and for
    /// different bots. Can't be used to download or reuse the file.
    public var fileUniqueId: Swift.String

    /// Video width as defined by the sender
    public var width: Swift.Int64

    /// Video height as defined by the sender
    public var height: Swift.Int64

    /// Duration of the video in seconds as defined by the sender
    public var duration: Swift.Int64

    /// *Optional*. Video thumbnail
    public var thumbnail: PhotoSize?

    /// *Optional*. Available sizes of the cover of the video in the message
    public var cover: [PhotoSize]?

    /// *Optional*. Timestamp in seconds from which the video will play in the message
    public var startTimestamp: Swift.Int64?

    /// *Optional*. List of available qualities of the video
    public var qualities: [VideoQuality]?

    /// *Optional*. Original filename as defined by the sender
    public var fileName: Swift.String?

    /// *Optional*. MIME type of the file as defined by the sender
    public var mimeType: Swift.String?

    /// *Optional*. File size in bytes. It can be bigger than 2^31 and some programming
    /// languages may have difficulty/silent defects in interpreting it. But it has at most 52
    /// significant bits, so a signed 64-bit integer or double-precision float type are safe for
    /// storing this value.
    public var fileSize: Swift.Int64?

    public init(
        fileId: Swift.String,
        fileUniqueId: Swift.String,
        width: Swift.Int64,
        height: Swift.Int64,
        duration: Swift.Int64,
        thumbnail: PhotoSize? = nil,
        cover: [PhotoSize]? = nil,
        startTimestamp: Swift.Int64? = nil,
        qualities: [VideoQuality]? = nil,
        fileName: Swift.String? = nil,
        mimeType: Swift.String? = nil,
        fileSize: Swift.Int64? = nil
    ) {
        self.fileId = fileId
        self.fileUniqueId = fileUniqueId
        self.width = width
        self.height = height
        self.duration = duration
        self.thumbnail = thumbnail
        self.cover = cover
        self.startTimestamp = startTimestamp
        self.qualities = qualities
        self.fileName = fileName
        self.mimeType = mimeType
        self.fileSize = fileSize
    }

    public enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case width
        case height
        case duration
        case thumbnail
        case cover
        case startTimestamp = "start_timestamp"
        case qualities
        case fileName = "file_name"
        case mimeType = "mime_type"
        case fileSize = "file_size"
    }
}
