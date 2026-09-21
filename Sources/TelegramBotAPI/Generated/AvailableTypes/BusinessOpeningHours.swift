// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes the opening hours of a business.
public struct BusinessOpeningHours: Codable, Hashable, Sendable {
    /// Unique name of the time zone for which the opening hours are defined
    public var timeZoneName: Swift.String

    /// List of time intervals describing business opening hours
    public var openingHours: [BusinessOpeningHoursInterval]

    public init(
        timeZoneName: Swift.String,
        openingHours: [BusinessOpeningHoursInterval]
    ) {
        self.timeZoneName = timeZoneName
        self.openingHours = openingHours
    }

    public enum CodingKeys: String, CodingKey {
        case timeZoneName = "time_zone_name"
        case openingHours = "opening_hours"
    }
}
