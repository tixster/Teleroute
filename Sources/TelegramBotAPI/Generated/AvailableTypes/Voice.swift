// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a voice note.
public struct Voice: Codable, Hashable, Sendable {
    /// Identifier for this file, which can be used to download or reuse the file
    public var fileId: Swift.String

    /// Unique identifier for this file, which is supposed to be the same over time and for
    /// different bots. Can't be used to download or reuse the file.
    public var fileUniqueId: Swift.String

    /// Duration of the audio in seconds as defined by the sender
    public var duration: Swift.Int64

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
        duration: Swift.Int64,
        mimeType: Swift.String? = nil,
        fileSize: Swift.Int64? = nil
    ) {
        self.fileId = fileId
        self.fileUniqueId = fileUniqueId
        self.duration = duration
        self.mimeType = mimeType
        self.fileSize = fileSize
    }

    public enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case duration
        case mimeType = "mime_type"
        case fileSize = "file_size"
    }
}
