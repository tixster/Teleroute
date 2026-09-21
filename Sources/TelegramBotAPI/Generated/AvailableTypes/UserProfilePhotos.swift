// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represent a user's profile pictures.
public struct UserProfilePhotos: Codable, Hashable, Sendable {
    /// Total number of profile pictures the target user has
    public var totalCount: Swift.Int64

    /// Requested profile pictures (in up to 4 sizes each)
    public var photos: [[PhotoSize]]

    public init(
        totalCount: Swift.Int64,
        photos: [[PhotoSize]]
    ) {
        self.totalCount = totalCount
        self.photos = photos
    }

    public enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case photos
    }
}
