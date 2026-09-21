// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents the `scope` of bot commands, covering all group and supergroup chat
/// administrators.
public struct BotCommandScopeAllChatAdministrators: Codable, Hashable, Sendable {
    /// Scope type, must be *all_chat_administrators*
    public var type: BotCommandScopeKind

    public init(
        type: BotCommandScopeKind = .allChatAdministrators
    ) {
        self.type = type
    }

    public enum CodingKeys: String, CodingKey {
        case type
    }
}
