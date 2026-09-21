// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents the `content` of a location message to be sent as the result of an inline query.
public struct InputLocationMessageContent: Codable, Hashable, Sendable {
    /// Latitude of the location in degrees
    public var latitude: Swift.Double

    /// Longitude of the location in degrees
    public var longitude: Swift.Double

    /// *Optional*. The radius of uncertainty for the location, measured in meters; 0-1500
    public var horizontalAccuracy: Swift.Double?

    /// *Optional*. Period in seconds during which the location can be updated, must be between
    /// 60 and 86400, or 0x7FFFFFFF for live locations that can be edited indefinitely
    public var livePeriod: Swift.Int64?

    /// *Optional*. For live locations, a direction in which the user is moving, in degrees.
    /// Must be between 1 and 360 if specified.
    public var heading: Swift.Int64?

    /// *Optional*. For live locations, a maximum distance for proximity alerts about
    /// approaching another chat member, in meters. Must be between 1 and 100000 if specified.
    public var proximityAlertRadius: Swift.Int64?

    public init(
        latitude: Swift.Double,
        longitude: Swift.Double,
        horizontalAccuracy: Swift.Double? = nil,
        livePeriod: Swift.Int64? = nil,
        heading: Swift.Int64? = nil,
        proximityAlertRadius: Swift.Int64? = nil
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracy = horizontalAccuracy
        self.livePeriod = livePeriod
        self.heading = heading
        self.proximityAlertRadius = proximityAlertRadius
    }

    public enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case horizontalAccuracy = "horizontal_accuracy"
        case livePeriod = "live_period"
        case heading
        case proximityAlertRadius = "proximity_alert_radius"
    }
}
