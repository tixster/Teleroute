// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents the `scope` of bot commands, covering all private chats.
public struct BotCommandScopeAllPrivateChats: Codable, Hashable, Sendable {
    /// Scope type, must be *all_private_chats*
    public var type: BotCommandScopeKind

    public init(
        type: BotCommandScopeKind = .allPrivateChats
    ) {
        self.type = type
    }

    public enum CodingKeys: String, CodingKey {
        case type
    }
}
