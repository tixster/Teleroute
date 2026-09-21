// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The `type` a ``BackgroundType`` variant carries.
public enum BackgroundTypeKind: RawRepresentable, Codable, Hashable, Sendable {
    case fill
    case wallpaper
    case pattern
    case chatTheme
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .fill: "fill"
        case .wallpaper: "wallpaper"
        case .pattern: "pattern"
        case .chatTheme: "chat_theme"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "fill": self = .fill
        case "wallpaper": self = .wallpaper
        case "pattern": self = .pattern
        case "chat_theme": self = .chatTheme
        default: self = .unknown(rawValue)
        }
    }

    public init(from decoder: any Decoder) throws {
        self.init(rawValue: try decoder.singleValueContainer().decode(Swift.String.self))
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }

    /// Every value documented at the time these sources were generated.
    public static let documentedCases: [BackgroundTypeKind] = [
        .fill,
        .wallpaper,
        .pattern,
        .chatTheme,
    ]
}
