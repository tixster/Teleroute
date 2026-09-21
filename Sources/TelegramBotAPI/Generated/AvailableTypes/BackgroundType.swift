// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the type of a background. Currently, it can be one of
public enum BackgroundType: Codable, Hashable, Sendable {
    case fill(BackgroundTypeFill)
    case wallpaper(BackgroundTypeWallpaper)
    case pattern(BackgroundTypePattern)
    case chatTheme(BackgroundTypeChatTheme)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "fill":
            self = .fill(try BackgroundTypeFill(from: decoder))
        case "wallpaper":
            self = .wallpaper(try BackgroundTypeWallpaper(from: decoder))
        case "pattern":
            self = .pattern(try BackgroundTypePattern(from: decoder))
        case "chat_theme":
            self = .chatTheme(try BackgroundTypeChatTheme(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown BackgroundType type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .fill(value):
            try value.encode(to: encoder)
        case let .wallpaper(value):
            try value.encode(to: encoder)
        case let .pattern(value):
            try value.encode(to: encoder)
        case let .chatTheme(value):
            try value.encode(to: encoder)
        }
    }
}
