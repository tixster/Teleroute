// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a file ready to be downloaded. The file can be downloaded via the
/// link `https://api.telegram.org/file/bot<token>/<file_path>`. It is guaranteed that the link
/// will be valid for at least 1 hour. When the link expires, a new one can be requested by
/// calling `getFile`. The maximum file size to download is 20 MB
public struct File: Codable, Hashable, Sendable {
    /// Identifier for this file, which can be used to download or reuse the file
    public var fileId: Swift.String

    /// Unique identifier for this file, which is supposed to be the same over time and for
    /// different bots. Can't be used to download or reuse the file.
    public var fileUniqueId: Swift.String

    /// *Optional*. File size in bytes. It can be bigger than 2^31 and some programming
    /// languages may have difficulty/silent defects in interpreting it. But it has at most 52
    /// significant bits, so a signed 64-bit integer or double-precision float type are safe for
    /// storing this value.
    public var fileSize: Swift.Int64?

    /// *Optional*. File path. Use `https://api.telegram.org/file/bot<token>/<file_path>` to get
    /// the file.
    public var filePath: Swift.String?

    public init(
        fileId: Swift.String,
        fileUniqueId: Swift.String,
        fileSize: Swift.Int64? = nil,
        filePath: Swift.String? = nil
    ) {
        self.fileId = fileId
        self.fileUniqueId = fileUniqueId
        self.fileSize = fileSize
        self.filePath = filePath
    }

    public enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case fileSize = "file_size"
        case filePath = "file_path"
    }
}
