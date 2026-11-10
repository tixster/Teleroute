// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents an incoming query from a forwarded message with a shared widget
/// created by the bot. Use `answerWidgetQuery` to answer the query. Each user can send at most
/// 5 queries per 5 seconds to the bot from all its widgets.
public struct SharedWidgetQuery: Codable, Hashable, Sendable {
    /// Unique identifier for this query
    public var id: Swift.String

    private var fromBox: _IndirectBox<User>
    /// Sender
    public var from: User {
        get { self.fromBox.value }
        set { self.fromBox = _IndirectBox(newValue) }
    }

    /// Type of the query
    public var type: WidgetQueryType

    /// Data of the query, 1-64 bytes
    public var data: Swift.String

    /// Unique identifier of the shared widget, which sent the query
    public var widgetId: Swift.String

    public init(
        id: Swift.String,
        from: User,
        type: WidgetQueryType,
        data: Swift.String,
        widgetId: Swift.String
    ) {
        self.id = id
        self.fromBox = _IndirectBox(from)
        self.type = type
        self.data = data
        self.widgetId = widgetId
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case fromBox = "from"
        case type
        case data
        case widgetId = "widget_id"
    }
}
