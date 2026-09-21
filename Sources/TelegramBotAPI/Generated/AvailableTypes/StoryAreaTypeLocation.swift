// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a story area pointing to a location. Currently, a story can have up to 10 location
/// areas.
public struct StoryAreaTypeLocation: Codable, Hashable, Sendable {
    /// Type of the area, always “location”
    public var type: StoryAreaTypeKind

    /// Location latitude in degrees
    public var latitude: Swift.Double

    /// Location longitude in degrees
    public var longitude: Swift.Double

    /// *Optional*. Address of the location
    public var address: LocationAddress?

    public init(
        type: StoryAreaTypeKind = .location,
        latitude: Swift.Double,
        longitude: Swift.Double,
        address: LocationAddress? = nil
    ) {
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case latitude
        case longitude
        case address
    }
}
