// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a chat photo.
public struct ChatPhoto: Codable, Hashable, Sendable {
    /// File identifier of small (160x160) chat photo. This file_id can be used only for photo
    /// download and only for as long as the photo is not changed.
    public var smallFileId: Swift.String

    /// Unique file identifier of small (160x160) chat photo, which is supposed to be the same
    /// over time and for different bots. Can't be used to download or reuse the file.
    public var smallFileUniqueId: Swift.String

    /// File identifier of big (640x640) chat photo. This file_id can be used only for photo
    /// download and only for as long as the photo is not changed.
    public var bigFileId: Swift.String

    /// Unique file identifier of big (640x640) chat photo, which is supposed to be the same
    /// over time and for different bots. Can't be used to download or reuse the file.
    public var bigFileUniqueId: Swift.String

    public init(
        smallFileId: Swift.String,
        smallFileUniqueId: Swift.String,
        bigFileId: Swift.String,
        bigFileUniqueId: Swift.String
    ) {
        self.smallFileId = smallFileId
        self.smallFileUniqueId = smallFileUniqueId
        self.bigFileId = bigFileId
        self.bigFileUniqueId = bigFileUniqueId
    }

    public enum CodingKeys: String, CodingKey {
        case smallFileId = "small_file_id"
        case smallFileUniqueId = "small_file_unique_id"
        case bigFileId = "big_file_id"
        case bigFileUniqueId = "big_file_unique_id"
    }
}
