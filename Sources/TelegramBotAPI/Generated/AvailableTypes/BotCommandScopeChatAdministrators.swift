// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents the `scope` of bot commands, covering all administrators of a specific group or
/// supergroup chat.
public struct BotCommandScopeChatAdministrators: Codable, Hashable, Sendable {
    /// Scope type, must be *chat_administrators*
    public var type: BotCommandScopeKind

    /// Unique identifier for the target chat or username of the target supergroup in the format
    /// `@username`. Channel direct messages chats and channel chats aren't supported.
    public var chatId: ChatId

    public init(
        type: BotCommandScopeKind = .chatAdministrators,
        chatId: ChatId
    ) {
        self.type = type
        self.chatId = chatId
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case chatId = "chat_id"
    }
}
