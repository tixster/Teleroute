// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a file uploaded to Telegram Passport. Currently all Telegram Passport
/// files are in JPEG format when decrypted and don't exceed 10MB.
public struct PassportFile: Codable, Hashable, Sendable {
    /// Identifier for this file, which can be used to download or reuse the file
    public var fileId: Swift.String

    /// Unique identifier for this file, which is supposed to be the same over time and for
    /// different bots. Can't be used to download or reuse the file.
    public var fileUniqueId: Swift.String

    /// File size in bytes
    public var fileSize: Swift.Int64

    /// Unix time when the file was uploaded
    public var fileDate: Swift.Int64

    public init(
        fileId: Swift.String,
        fileUniqueId: Swift.String,
        fileSize: Swift.Int64,
        fileDate: Swift.Int64
    ) {
        self.fileId = fileId
        self.fileUniqueId = fileUniqueId
        self.fileSize = fileSize
        self.fileDate = fileDate
    }

    public enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case fileSize = "file_size"
        case fileDate = "file_date"
    }
}
