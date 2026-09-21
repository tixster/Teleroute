// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a [video
/// message](https://telegram.org/blog/video-messages-and-telescope).
public struct VideoNote: Codable, Hashable, Sendable {
    /// Identifier for this file, which can be used to download or reuse the file
    public var fileId: Swift.String

    /// Unique identifier for this file, which is supposed to be the same over time and for
    /// different bots. Can't be used to download or reuse the file.
    public var fileUniqueId: Swift.String

    /// Video width and height (diameter of the video message) as defined by the sender
    public var length: Swift.Int64

    /// Duration of the video in seconds as defined by the sender
    public var duration: Swift.Int64

    /// *Optional*. Video thumbnail
    public var thumbnail: PhotoSize?

    /// *Optional*. File size in bytes
    public var fileSize: Swift.Int64?

    public init(
        fileId: Swift.String,
        fileUniqueId: Swift.String,
        length: Swift.Int64,
        duration: Swift.Int64,
        thumbnail: PhotoSize? = nil,
        fileSize: Swift.Int64? = nil
    ) {
        self.fileId = fileId
        self.fileUniqueId = fileUniqueId
        self.length = length
        self.duration = duration
        self.thumbnail = thumbnail
        self.fileSize = fileSize
    }

    public enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case length
        case duration
        case thumbnail
        case fileSize = "file_size"
    }
}
