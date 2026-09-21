// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents one size of a photo or a `file` / `sticker` thumbnail.
public struct PhotoSize: Codable, Hashable, Sendable {
    /// Identifier for this file, which can be used to download or reuse the file
    public var fileId: Swift.String

    /// Unique identifier for this file, which is supposed to be the same over time and for
    /// different bots. Can't be used to download or reuse the file.
    public var fileUniqueId: Swift.String

    /// Photo width
    public var width: Swift.Int64

    /// Photo height
    public var height: Swift.Int64

    /// *Optional*. File size in bytes
    public var fileSize: Swift.Int64?

    public init(
        fileId: Swift.String,
        fileUniqueId: Swift.String,
        width: Swift.Int64,
        height: Swift.Int64,
        fileSize: Swift.Int64? = nil
    ) {
        self.fileId = fileId
        self.fileUniqueId = fileUniqueId
        self.width = width
        self.height = height
        self.fileSize = fileSize
    }

    public enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case width
        case height
        case fileSize = "file_size"
    }
}
