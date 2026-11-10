// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents the `content` of a message with a shared widget to be sent as the result of an
/// inline query. Currently, widgets can't be sent in response to inline queries in the
/// production environment.
public struct InputSharedWidgetMessageContent: Codable, Hashable, Sendable {
    /// Unique identifier of the shared widget created by the bot
    public var widgetId: Swift.String

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

    public init(
        widgetId: Swift.String,
        chatData: Swift.String? = nil,
        caption: Swift.String? = nil,
        parseMode: Swift.String? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Swift.Bool? = nil
    ) {
        self.widgetId = widgetId
        self.chatData = chatData
        self.caption = caption
        self.parseMode = parseMode
        self.captionEntities = captionEntities
        self.showCaptionAboveMedia = showCaptionAboveMedia
    }

    public enum CodingKeys: String, CodingKey {
        case widgetId = "widget_id"
        case chatData = "chat_data"
        case caption
        case parseMode = "parse_mode"
        case captionEntities = "caption_entities"
        case showCaptionAboveMedia = "show_caption_above_media"
    }
}
