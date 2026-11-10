// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents the `content` of a message with an HTML widget to be sent as the result of an
/// inline query. Currently, widgets can't be sent in response to inline queries in the
/// production environment.
public struct InputWidgetMessageContent: Codable, Hashable, Sendable {
    /// HTML code of the widget, 1-32768 bytes. The code must not exceed 4096 bytes when
    /// compressed by zlib with the maximum compression level.
    public var html: Swift.String

    /// *Optional*. Width of the widget in logical pixels; omit if the widget must occupy the
    /// whole width of the message bubble. The width is clamped by the app to the range from 200
    /// to the maximum width of the message bubble.
    public var width: Swift.Int64?

    /// *Optional*. Height of the widget in logical pixels; omit if the height of the widget
    /// isn't fixed. The height is clamped by the app to the range 50-600.
    public var height: Swift.Int64?

    /// *Optional*. Public data of the widget, 0-1024 bytes, which will be available wherever
    /// the widget is shown. If the widget is shared, then all messages with it will have the
    /// same public data.
    public var publicData: Swift.String?

    /// *Optional*. Data of the widget, which is specific to the message, 0-1024 bytes
    public var chatData: Swift.String?

    /// *Optional*. Widget caption, 0-1024 characters after entities parsing
    public var caption: Swift.String?

    /// *Optional*. Mode for parsing entities in the widget caption. See formatting options for
    /// more details.
    public var parseMode: Swift.String?

    /// *Optional*. List of special entities that appear in the caption, which can be specified
    /// instead of *parse_mode*
    public var captionEntities: [MessageEntity]?

    /// *Optional*. Pass *True* if the caption must be shown above the widget
    public var showCaptionAboveMedia: Swift.Bool?

    /// *Optional*. Pass *True* to allow the widget to send queries to the bot
    public var allowQueries: Swift.Bool?

    /// *Optional*. Pass *True* to create a shared widget. Each message sent from the result
    /// creates a separate shared widget, whose identifier is received by the bot only in the
    /// field *widget_id* of queries from the widget. To send an existing shared widget in
    /// response to an inline query, use ``InputSharedWidgetMessageContent`` instead.
    public var isShared: Swift.Bool?

    public init(
        html: Swift.String,
        width: Swift.Int64? = nil,
        height: Swift.Int64? = nil,
        publicData: Swift.String? = nil,
        chatData: Swift.String? = nil,
        caption: Swift.String? = nil,
        parseMode: Swift.String? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Swift.Bool? = nil,
        allowQueries: Swift.Bool? = nil,
        isShared: Swift.Bool? = nil
    ) {
        self.html = html
        self.width = width
        self.height = height
        self.publicData = publicData
        self.chatData = chatData
        self.caption = caption
        self.parseMode = parseMode
        self.captionEntities = captionEntities
        self.showCaptionAboveMedia = showCaptionAboveMedia
        self.allowQueries = allowQueries
        self.isShared = isShared
    }

    public enum CodingKeys: String, CodingKey {
        case html
        case width
        case height
        case publicData = "public_data"
        case chatData = "chat_data"
        case caption
        case parseMode = "parse_mode"
        case captionEntities = "caption_entities"
        case showCaptionAboveMedia = "show_caption_above_media"
        case allowQueries = "allow_queries"
        case isShared = "is_shared"
    }
}
