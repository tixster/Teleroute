// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a menu button, which opens the bot's list of commands.
public struct MenuButtonCommands: Codable, Hashable, Sendable {
    /// Type of the button, must be *commands*
    public var type: MenuButtonKind

    public init(
        type: MenuButtonKind = .commands
    ) {
        self.type = type
    }

    public enum CodingKeys: String, CodingKey {
        case type
    }
}
