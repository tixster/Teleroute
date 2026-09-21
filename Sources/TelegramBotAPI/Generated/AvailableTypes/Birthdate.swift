// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes the birthdate of a user.
public struct Birthdate: Codable, Hashable, Sendable {
    /// Day of the user's birth; 1-31
    public var day: Swift.Int64

    /// Month of the user's birth; 1-12
    public var month: Swift.Int64

    /// *Optional*. Year of the user's birth
    public var year: Swift.Int64?

    public init(
        day: Swift.Int64,
        month: Swift.Int64,
        year: Swift.Int64? = nil
    ) {
        self.day = day
        self.month = month
        self.year = year
    }

    public enum CodingKeys: String, CodingKey {
        case day
        case month
        case year
    }
}
