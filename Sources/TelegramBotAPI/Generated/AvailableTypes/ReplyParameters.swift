// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes reply parameters for the message that is being sent.
public struct ReplyParameters: Codable, Hashable, Sendable {
    /// *Optional*. Identifier of the message that will be replied to in the current chat, or in
    /// the chat *chat_id* if it is specified. Required if *ephemeral_message_id* isn't
    /// specified.
    public var messageId: Swift.Int64?

    /// *Optional*. If the message to be replied to is from a different chat, unique identifier
    /// for the chat or username of the bot, supergroup or channel in the format `@username`.
    /// Not supported for messages sent on behalf of a business account, messages from channel
    /// direct messages chats and ephemeral messages.
    public var chatId: ChatId?

    /// *Optional*. Identifier of the incoming ephemeral message that will be replied to in the
    /// current chat. A reply to an ephemeral message must itself be an ephemeral message. An
    /// ephemeral message may only be replied to within 15 seconds of being sent. Required if
    /// *message_id* isn't specified.
    public var ephemeralMessageId: Swift.Int64?

    /// *Optional*. Pass *True* if the message should be sent even if the specified message to
    /// be replied to is not found. Always *False* for replies in another chat or forum topic,
    /// and sent ephemeral messages. Always *True* for messages sent on behalf of a business
    /// account.
    public var allowSendingWithoutReply: Swift.Bool?

    /// *Optional*. Quoted part of the message to be replied to; 0-1024 characters after
    /// entities parsing. The quote must be an exact substring of the message to be replied to,
    /// including *bold*, *italic*, *underline*, *strikethrough*, *spoiler*, *custom_emoji*, and
    /// *date_time* entities. The message will fail to send if the quote isn't found in the
    /// original message. Ignored for ephemeral messages.
    public var quote: Swift.String?

    /// *Optional*. Mode for parsing entities in the quote. See formatting options for more
    /// details.
    public var quoteParseMode: Swift.String?

    /// *Optional*. A JSON-serialized list of special entities that appear in the quote. It can
    /// be specified instead of *quote_parse_mode*.
    public var quoteEntities: [MessageEntity]?

    /// *Optional*. Position of the quote in the original message in UTF-16 code units
    public var quotePosition: Swift.Int64?

    /// *Optional*. Identifier of the specific checklist task to be replied to
    public var checklistTaskId: Swift.Int64?

    /// *Optional*. Persistent identifier of the specific poll option to be replied to
    public var pollOptionId: Swift.String?

    public init(
        messageId: Swift.Int64? = nil,
        chatId: ChatId? = nil,
        ephemeralMessageId: Swift.Int64? = nil,
        allowSendingWithoutReply: Swift.Bool? = nil,
        quote: Swift.String? = nil,
        quoteParseMode: Swift.String? = nil,
        quoteEntities: [MessageEntity]? = nil,
        quotePosition: Swift.Int64? = nil,
        checklistTaskId: Swift.Int64? = nil,
        pollOptionId: Swift.String? = nil
    ) {
        self.messageId = messageId
        self.chatId = chatId
        self.ephemeralMessageId = ephemeralMessageId
        self.allowSendingWithoutReply = allowSendingWithoutReply
        self.quote = quote
        self.quoteParseMode = quoteParseMode
        self.quoteEntities = quoteEntities
        self.quotePosition = quotePosition
        self.checklistTaskId = checklistTaskId
        self.pollOptionId = pollOptionId
    }

    public enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case chatId = "chat_id"
        case ephemeralMessageId = "ephemeral_message_id"
        case allowSendingWithoutReply = "allow_sending_without_reply"
        case quote
        case quoteParseMode = "quote_parse_mode"
        case quoteEntities = "quote_entities"
        case quotePosition = "quote_position"
        case checklistTaskId = "checklist_task_id"
        case pollOptionId = "poll_option_id"
    }
}
