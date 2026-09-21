// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a `result` of an inline query that was chosen by the user and sent to their chat
/// partner.
public struct ChosenInlineResult: Codable, Hashable, Sendable {
    /// The unique identifier for the result that was chosen
    public var resultId: Swift.String

    private var fromBox: _IndirectBox<User>
    /// The user that chose the result
    public var from: User {
        get { self.fromBox.value }
        set { self.fromBox = _IndirectBox(newValue) }
    }

    /// *Optional*. Sender location, only for bots that require user location
    public var location: Location?

    /// *Optional*. Identifier of the sent inline message. Available only if there is an inline
    /// keyboard attached to the message. Will be also received in callback queries and can be
    /// used to `edit` the message.
    public var inlineMessageId: Swift.String?

    /// The query that was used to obtain the result
    public var query: Swift.String

    public init(
        resultId: Swift.String,
        from: User,
        location: Location? = nil,
        inlineMessageId: Swift.String? = nil,
        query: Swift.String
    ) {
        self.resultId = resultId
        self.fromBox = _IndirectBox(from)
        self.location = location
        self.inlineMessageId = inlineMessageId
        self.query = query
    }

    public enum CodingKeys: String, CodingKey {
        case resultId = "result_id"
        case fromBox = "from"
        case location
        case inlineMessageId = "inline_message_id"
        case query
    }
}
