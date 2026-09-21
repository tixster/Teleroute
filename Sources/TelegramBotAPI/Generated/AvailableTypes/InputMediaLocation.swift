// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a location to be sent.
public struct InputMediaLocation: Codable, Hashable, Sendable {
    /// Type of the media, must be *location*
    public var type: InputPollMediaKind

    /// Latitude of the location
    public var latitude: Swift.Double

    /// Longitude of the location
    public var longitude: Swift.Double

    /// *Optional*. The radius of uncertainty for the location, measured in meters; 0-1500
    public var horizontalAccuracy: Swift.Double?

    public init(
        type: InputPollMediaKind = .location,
        latitude: Swift.Double,
        longitude: Swift.Double,
        horizontalAccuracy: Swift.Double? = nil
    ) {
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracy = horizontalAccuracy
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case latitude
        case longitude
        case horizontalAccuracy = "horizontal_accuracy"
    }
}
