// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes an HTML widget.
public struct Widget: Codable, Hashable, Sendable {
    /// *Optional*. Unique identifier of the shared widget, which can be used to send the widget
    /// again using the method `sendSharedWidget`; omitted if the widget isn't shared
    public var id: Swift.String?

    /// *Optional*. Width of the widget in logical pixels; omitted if the widget must occupy the
    /// whole width of the message bubble
    public var width: Swift.Int64?

    /// *Optional*. Height of the widget in logical pixels; omitted if the height of the widget
    /// isn't fixed
    public var height: Swift.Int64?

    /// HTML code of the widget
    public var html: Swift.String

    /// *Optional*. Public data of the widget, which is available wherever the widget is shown.
    /// All messages with a shared widget have the same public data.
    public var publicData: Swift.String?

    /// *Optional*. Data of the widget, which is specific to the message
    public var chatData: Swift.String?

    public init(
        id: Swift.String? = nil,
        width: Swift.Int64? = nil,
        height: Swift.Int64? = nil,
        html: Swift.String,
        publicData: Swift.String? = nil,
        chatData: Swift.String? = nil
    ) {
        self.id = id
        self.width = width
        self.height = height
        self.html = html
        self.publicData = publicData
        self.chatData = chatData
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case html
        case publicData = "public_data"
        case chatData = "chat_data"
    }
}
