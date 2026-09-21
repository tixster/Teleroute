// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents the `scope` of bot commands, covering a specific member of a group or supergroup
/// chat.
public struct BotCommandScopeChatMember: Codable, Hashable, Sendable {
    /// Scope type, must be *chat_member*
    public var type: BotCommandScopeKind

    /// Unique identifier for the target chat or username of the target supergroup in the format
    /// `@username`. Channel direct messages chats and channel chats aren't supported.
    public var chatId: ChatId

    /// Unique identifier of the target user
    public var userId: Swift.Int64

    public init(
        type: BotCommandScopeKind = .chatMember,
        chatId: ChatId,
        userId: Swift.Int64
    ) {
        self.type = type
        self.chatId = chatId
        self.userId = userId
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case chatId = "chat_id"
        case userId = "user_id"
    }
}
