// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains information about a chat that was shared with the bot using a
/// ``KeyboardButtonRequestChat`` button.
public struct ChatShared: Codable, Hashable, Sendable {
    /// Identifier of the request
    public var requestId: Swift.Int64

    /// Identifier of the shared chat. This number may have more than 32 significant bits and
    /// some programming languages may have difficulty/silent defects in interpreting it. But it
    /// has at most 52 significant bits, so a 64-bit integer or double-precision float type are
    /// safe for storing this identifier. The bot may not have access to the chat and could be
    /// unable to use this identifier, unless the chat is already known to the bot by some other
    /// means.
    public var chatId: Swift.Int64

    /// *Optional*. Title of the chat, if the title was requested by the bot
    public var title: Swift.String?

    /// *Optional*. Username of the chat, if the username was requested by the bot and available
    public var username: Swift.String?

    /// *Optional*. Available sizes of the chat photo, if the photo was requested by the bot
    public var photo: [PhotoSize]?

    public init(
        requestId: Swift.Int64,
        chatId: Swift.Int64,
        title: Swift.String? = nil,
        username: Swift.String? = nil,
        photo: [PhotoSize]? = nil
    ) {
        self.requestId = requestId
        self.chatId = chatId
        self.title = title
        self.username = username
        self.photo = photo
    }

    public enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case chatId = "chat_id"
        case title
        case username
        case photo
    }
}
