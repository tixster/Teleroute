// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a venue. By default, the venue will be sent by the user. Alternatively, you can
/// use *input_message_content* to send a message with the specified content instead of the
/// venue.
public struct InlineQueryResultVenue: Codable, Hashable, Sendable {
    /// Type of the result, must be *venue*
    public var type: InlineQueryResultKind

    /// Unique identifier for this result, 1-64 Bytes
    public var id: Swift.String

    /// Latitude of the venue location in degrees
    public var latitude: Swift.Double

    /// Longitude of the venue location in degrees
    public var longitude: Swift.Double

    /// Title of the venue
    public var title: Swift.String

    /// Address of the venue
    public var address: Swift.String

    /// *Optional*. Foursquare identifier of the venue if known
    public var foursquareId: Swift.String?

    /// *Optional*. Foursquare type of the venue, if known. (For example,
    /// “arts_entertainment/default”, “arts_entertainment/aquarium” or “food/icecream”.)
    public var foursquareType: Swift.String?

    /// *Optional*. Google Places identifier of the venue
    public var googlePlaceId: Swift.String?

    /// *Optional*. Google Places type of the venue. (See [supported
    /// types](https://developers.google.com/places/web-service/supported_types).)
    public var googlePlaceType: Swift.String?

    /// *Optional*. Inline keyboard attached to the message
    public var replyMarkup: InlineKeyboardMarkup?

    private var inputMessageContentBox: _IndirectBox<InputMessageContent>?
    /// *Optional*. Content of the message to be sent instead of the venue
    public var inputMessageContent: InputMessageContent? {
        get { self.inputMessageContentBox?.value }
        set { self.inputMessageContentBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Url of the thumbnail for the result
    public var thumbnailUrl: Swift.String?

    /// *Optional*. Thumbnail width
    public var thumbnailWidth: Swift.Int64?

    /// *Optional*. Thumbnail height
    public var thumbnailHeight: Swift.Int64?

    public init(
        type: InlineQueryResultKind = .venue,
        id: Swift.String,
        latitude: Swift.Double,
        longitude: Swift.Double,
        title: Swift.String,
        address: Swift.String,
        foursquareId: Swift.String? = nil,
        foursquareType: Swift.String? = nil,
        googlePlaceId: Swift.String? = nil,
        googlePlaceType: Swift.String? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil,
        inputMessageContent: InputMessageContent? = nil,
        thumbnailUrl: Swift.String? = nil,
        thumbnailWidth: Swift.Int64? = nil,
        thumbnailHeight: Swift.Int64? = nil
    ) {
        self.type = type
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
        self.address = address
        self.foursquareId = foursquareId
        self.foursquareType = foursquareType
        self.googlePlaceId = googlePlaceId
        self.googlePlaceType = googlePlaceType
        self.replyMarkup = replyMarkup
        self.inputMessageContentBox = inputMessageContent.map(_IndirectBox.init)
        self.thumbnailUrl = thumbnailUrl
        self.thumbnailWidth = thumbnailWidth
        self.thumbnailHeight = thumbnailHeight
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case id
        case latitude
        case longitude
        case title
        case address
        case foursquareId = "foursquare_id"
        case foursquareType = "foursquare_type"
        case googlePlaceId = "google_place_id"
        case googlePlaceType = "google_place_type"
        case replyMarkup = "reply_markup"
        case inputMessageContentBox = "input_message_content"
        case thumbnailUrl = "thumbnail_url"
        case thumbnailWidth = "thumbnail_width"
        case thumbnailHeight = "thumbnail_height"
    }
}
