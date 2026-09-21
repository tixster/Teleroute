// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes that no specific value for the menu button was set.
public struct MenuButtonDefault: Codable, Hashable, Sendable {
    /// Type of the button, must be *default*
    public var type: MenuButtonKind

    public init(
        type: MenuButtonKind = .default
    ) {
        self.type = type
    }

    public enum CodingKeys: String, CodingKey {
        case type
    }
}
