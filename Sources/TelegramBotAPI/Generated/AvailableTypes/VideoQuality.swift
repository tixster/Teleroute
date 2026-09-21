// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a video file of a specific quality.
public struct VideoQuality: Codable, Hashable, Sendable {
    /// Identifier for this file, which can be used to download or reuse the file
    public var fileId: Swift.String

    /// Unique identifier for this file, which is supposed to be the same over time and for
    /// different bots. Can't be used to download or reuse the file.
    public var fileUniqueId: Swift.String

    /// Video width
    public var width: Swift.Int64

    /// Video height
    public var height: Swift.Int64

    /// Codec that was used to encode the video, for example, “h264”, “h265”, or “av01”
    public var codec: Swift.String

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
        codec: Swift.String,
        fileSize: Swift.Int64? = nil
    ) {
        self.fileId = fileId
        self.fileUniqueId = fileUniqueId
        self.width = width
        self.height = height
        self.codec = codec
        self.fileSize = fileSize
    }

    public enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case width
        case height
        case codec
        case fileSize = "file_size"
    }
}
