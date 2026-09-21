// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents the `scope` of bot commands, covering all group and supergroup chats.
public struct BotCommandScopeAllGroupChats: Codable, Hashable, Sendable {
    /// Scope type, must be *all_group_chats*
    public var type: BotCommandScopeKind

    public init(
        type: BotCommandScopeKind = .allGroupChats
    ) {
        self.type = type
    }

    public enum CodingKeys: String, CodingKey {
        case type
    }
}
