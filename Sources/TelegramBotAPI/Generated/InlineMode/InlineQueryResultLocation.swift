// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a location on a map. By default, the location will be sent by the user.
/// Alternatively, you can use *input_message_content* to send a message with the specified
/// content instead of the location.
public struct InlineQueryResultLocation: Codable, Hashable, Sendable {
    /// Type of the result, must be *location*
    public var type: InlineQueryResultKind

    /// Unique identifier for this result, 1-64 Bytes
    public var id: Swift.String

    /// Location latitude in degrees
    public var latitude: Swift.Double

    /// Location longitude in degrees
    public var longitude: Swift.Double

    /// Location title
    public var title: Swift.String

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

    /// *Optional*. Inline keyboard attached to the message
    public var replyMarkup: InlineKeyboardMarkup?

    private var inputMessageContentBox: _IndirectBox<InputMessageContent>?
    /// *Optional*. Content of the message to be sent instead of the location
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
        type: InlineQueryResultKind = .location,
        id: Swift.String,
        latitude: Swift.Double,
        longitude: Swift.Double,
        title: Swift.String,
        horizontalAccuracy: Swift.Double? = nil,
        livePeriod: Swift.Int64? = nil,
        heading: Swift.Int64? = nil,
        proximityAlertRadius: Swift.Int64? = nil,
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
        self.horizontalAccuracy = horizontalAccuracy
        self.livePeriod = livePeriod
        self.heading = heading
        self.proximityAlertRadius = proximityAlertRadius
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
        case horizontalAccuracy = "horizontal_accuracy"
        case livePeriod = "live_period"
        case heading
        case proximityAlertRadius = "proximity_alert_radius"
        case replyMarkup = "reply_markup"
        case inputMessageContentBox = "input_message_content"
        case thumbnailUrl = "thumbnail_url"
        case thumbnailWidth = "thumbnail_width"
        case thumbnailHeight = "thumbnail_height"
    }
}
