// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents the default `scope` of bot commands. Default commands are used if no commands
/// with a narrower scope are specified for the user.
public struct BotCommandScopeDefault: Codable, Hashable, Sendable {
    /// Scope type, must be *default*
    public var type: BotCommandScopeKind

    public init(
        type: BotCommandScopeKind = .default
    ) {
        self.type = type
    }

    public enum CodingKeys: String, CodingKey {
        case type
    }
}
