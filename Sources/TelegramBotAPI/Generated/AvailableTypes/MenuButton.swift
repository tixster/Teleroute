// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the bot's menu button in a private chat. It should be one of If a menu
/// button other than ``MenuButtonDefault`` is set for a private chat, then it is applied in the
/// chat. Otherwise the default menu button is applied. By default, the menu button opens the
/// list of bot commands.
public enum MenuButton: Codable, Hashable, Sendable {
    case commands(MenuButtonCommands)
    case webApp(MenuButtonWebApp)
    case _default(MenuButtonDefault)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "commands":
            self = .commands(try MenuButtonCommands(from: decoder))
        case "web_app":
            self = .webApp(try MenuButtonWebApp(from: decoder))
        case "default":
            self = ._default(try MenuButtonDefault(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown MenuButton type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .commands(value):
            try value.encode(to: encoder)
        case let .webApp(value):
            try value.encode(to: encoder)
        case let ._default(value):
            try value.encode(to: encoder)
        }
    }
}
