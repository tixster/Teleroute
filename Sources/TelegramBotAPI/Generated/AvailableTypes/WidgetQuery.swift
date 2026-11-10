// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents an incoming query from a widget in a message sent by the bot or via
/// the bot. Use `answerWidgetQuery` to answer the query. Each user can send at most 5 queries
/// per 5 seconds to the bot from all its widgets.
public struct WidgetQuery: Codable, Hashable, Sendable {
    /// Unique identifier for this query
    public var id: Swift.String

    private var fromBox: _IndirectBox<User>
    /// Sender
    public var from: User {
        get { self.fromBox.value }
        set { self.fromBox = _IndirectBox(newValue) }
    }

    private var chatBox: _IndirectBox<Chat>?
    /// *Optional*. Chat with the message containing the widget; omitted if the widget is in an
    /// inline message
    public var chat: Chat? {
        get { self.chatBox?.value }
        set { self.chatBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Identifier of the message containing the widget; omitted if the widget is in
    /// an inline message
    public var messageId: Swift.Int64?

    /// *Optional*. Identifier of the inline message containing the widget
    public var inlineMessageId: Swift.String?

    /// Global identifier, uniquely corresponding to the chat to which the message with the
    /// widget was sent
    public var chatInstance: Swift.String

    /// *Optional*. For widgets in inline messages, type of the chat to which the message was
    /// sent. Can be either “sender” for a private chat with the inline query sender, “private”,
    /// “group”, “supergroup”, or “channel”.
    public var chatType: InlineQueryChatType?

    /// Type of the query
    public var type: WidgetQueryType

    /// Data of the query, 1-64 bytes
    public var data: Swift.String

    /// *Optional*. Unique identifier of the shared widget, which sent the query; omitted if the
    /// widget isn't shared
    public var widgetId: Swift.String?

    public init(
        id: Swift.String,
        from: User,
        chat: Chat? = nil,
        messageId: Swift.Int64? = nil,
        inlineMessageId: Swift.String? = nil,
        chatInstance: Swift.String,
        chatType: InlineQueryChatType? = nil,
        type: WidgetQueryType,
        data: Swift.String,
        widgetId: Swift.String? = nil
    ) {
        self.id = id
        self.fromBox = _IndirectBox(from)
        self.chatBox = chat.map(_IndirectBox.init)
        self.messageId = messageId
        self.inlineMessageId = inlineMessageId
        self.chatInstance = chatInstance
        self.chatType = chatType
        self.type = type
        self.data = data
        self.widgetId = widgetId
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case fromBox = "from"
        case chatBox = "chat"
        case messageId = "message_id"
        case inlineMessageId = "inline_message_id"
        case chatInstance = "chat_instance"
        case chatType = "chat_type"
        case type
        case data
        case widgetId = "widget_id"
    }
}
