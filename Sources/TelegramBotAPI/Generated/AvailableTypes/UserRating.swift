// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the rating of a user based on their Telegram Star spendings.
public struct UserRating: Codable, Hashable, Sendable {
    /// Current level of the user, indicating their reliability when purchasing digital goods
    /// and services. A higher level suggests a more trustworthy customer; a negative level is
    /// likely reason for concern.
    public var level: Swift.Int64

    /// Numerical value of the user's rating; the higher the rating, the better
    public var rating: Swift.Int64

    /// The rating value required to get the current level
    public var currentLevelRating: Swift.Int64

    /// *Optional*. The rating value required to get to the next level; omitted if the maximum
    /// level was reached
    public var nextLevelRating: Swift.Int64?

    public init(
        level: Swift.Int64,
        rating: Swift.Int64,
        currentLevelRating: Swift.Int64,
        nextLevelRating: Swift.Int64? = nil
    ) {
        self.level = level
        self.rating = rating
        self.currentLevelRating = currentLevelRating
        self.nextLevelRating = nextLevelRating
    }

    public enum CodingKeys: String, CodingKey {
        case level
        case rating
        case currentLevelRating = "current_level_rating"
        case nextLevelRating = "next_level_rating"
    }
}
