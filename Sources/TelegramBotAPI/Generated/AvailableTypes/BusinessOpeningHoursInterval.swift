// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes an interval of time during which a business is open.
public struct BusinessOpeningHoursInterval: Codable, Hashable, Sendable {
    /// The minute's sequence number in a week, starting on Monday, marking the start of the
    /// time interval during which the business is open; 0 - 7 * 24 * 60
    public var openingMinute: Swift.Int64

    /// The minute's sequence number in a week, starting on Monday, marking the end of the time
    /// interval during which the business is open; 0 - 8 * 24 * 60
    public var closingMinute: Swift.Int64

    public init(
        openingMinute: Swift.Int64,
        closingMinute: Swift.Int64
    ) {
        self.openingMinute = openingMinute
        self.closingMinute = closingMinute
    }

    public enum CodingKeys: String, CodingKey {
        case openingMinute = "opening_minute"
        case closingMinute = "closing_minute"
    }
}
