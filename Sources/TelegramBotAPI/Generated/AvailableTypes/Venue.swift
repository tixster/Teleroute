// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a venue.
public struct Venue: Codable, Hashable, Sendable {
    /// Venue location. Can't be a live location.
    public var location: Location

    /// Name of the venue
    public var title: Swift.String

    /// Address of the venue
    public var address: Swift.String

    /// *Optional*. Foursquare identifier of the venue
    public var foursquareId: Swift.String?

    /// *Optional*. Foursquare type of the venue. (For example, “arts_entertainment/default”,
    /// “arts_entertainment/aquarium” or “food/icecream”.)
    public var foursquareType: Swift.String?

    /// *Optional*. Google Places identifier of the venue
    public var googlePlaceId: Swift.String?

    /// *Optional*. Google Places type of the venue. (See [supported
    /// types](https://developers.google.com/places/web-service/supported_types).)
    public var googlePlaceType: Swift.String?

    public init(
        location: Location,
        title: Swift.String,
        address: Swift.String,
        foursquareId: Swift.String? = nil,
        foursquareType: Swift.String? = nil,
        googlePlaceId: Swift.String? = nil,
        googlePlaceType: Swift.String? = nil
    ) {
        self.location = location
        self.title = title
        self.address = address
        self.foursquareId = foursquareId
        self.foursquareType = foursquareType
        self.googlePlaceId = googlePlaceId
        self.googlePlaceType = googlePlaceType
    }

    public enum CodingKeys: String, CodingKey {
        case location
        case title
        case address
        case foursquareId = "foursquare_id"
        case foursquareType = "foursquare_type"
        case googlePlaceId = "google_place_id"
        case googlePlaceType = "google_place_type"
    }
}
