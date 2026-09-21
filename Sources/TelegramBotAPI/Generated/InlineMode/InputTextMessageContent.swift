// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents the `content` of a text message to be sent as the result of an inline query.
public struct InputTextMessageContent: Codable, Hashable, Sendable {
    /// Text of the message to be sent, 1-4096 characters
    public var messageText: Swift.String

    /// *Optional*. Mode for parsing entities in the message text. See formatting options for
    /// more details.
    public var parseMode: Swift.String?

    /// *Optional*. List of special entities that appear in message text, which can be specified
    /// instead of *parse_mode*
    public var entities: [MessageEntity]?

    /// *Optional*. Link preview generation options for the message
    public var linkPreviewOptions: LinkPreviewOptions?

    public init(
        messageText: Swift.String,
        parseMode: Swift.String? = nil,
        entities: [MessageEntity]? = nil,
        linkPreviewOptions: LinkPreviewOptions? = nil
    ) {
        self.messageText = messageText
        self.parseMode = parseMode
        self.entities = entities
        self.linkPreviewOptions = linkPreviewOptions
    }

    public enum CodingKeys: String, CodingKey {
        case messageText = "message_text"
        case parseMode = "parse_mode"
        case entities
        case linkPreviewOptions = "link_preview_options"
    }
}
