// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a point on the map.
public struct Location: Codable, Hashable, Sendable {
    /// Latitude as defined by the sender
    public var latitude: Swift.Double

    /// Longitude as defined by the sender
    public var longitude: Swift.Double

    /// *Optional*. The radius of uncertainty for the location, measured in meters; 0-1500
    public var horizontalAccuracy: Swift.Double?

    /// *Optional*. Time relative to the message sending date, during which the location can be
    /// updated; in seconds. For active live locations only.
    public var livePeriod: Swift.Int64?

    /// *Optional*. The direction in which user is moving, in degrees; 1-360. For active live
    /// locations only.
    public var heading: Swift.Int64?

    /// *Optional*. The maximum distance for proximity alerts about approaching another chat
    /// member, in meters. For sent live locations only.
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
