// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object is received when messages are deleted from a connected business account.
public struct BusinessMessagesDeleted: Codable, Hashable, Sendable {
    /// Unique identifier of the business connection
    public var businessConnectionId: Swift.String

    private var chatBox: _IndirectBox<Chat>
    /// Information about a chat in the business account. The bot may not have access to the
    /// chat or the corresponding user.
    public var chat: Chat {
        get { self.chatBox.value }
        set { self.chatBox = _IndirectBox(newValue) }
    }

    /// The list of identifiers of deleted messages in the chat of the business account
    public var messageIds: [Swift.Int64]

    public init(
        businessConnectionId: Swift.String,
        chat: Chat,
        messageIds: [Swift.Int64]
    ) {
        self.businessConnectionId = businessConnectionId
        self.chatBox = _IndirectBox(chat)
        self.messageIds = messageIds
    }

    public enum CodingKeys: String, CodingKey {
        case businessConnectionId = "business_connection_id"
        case chatBox = "chat"
        case messageIds = "message_ids"
    }
}
