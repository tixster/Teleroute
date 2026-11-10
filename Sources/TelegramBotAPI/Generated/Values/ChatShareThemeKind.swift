// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The `type` a ``ChatShareTheme`` variant carries.
public enum ChatShareThemeKind: RawRepresentable, Codable, Hashable, Sendable {
    case emoji
    case uniqueGift
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .emoji: "emoji"
        case .uniqueGift: "unique_gift"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "emoji": self = .emoji
        case "unique_gift": self = .uniqueGift
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
    public static let documentedCases: [ChatShareThemeKind] = [
        .emoji,
        .uniqueGift,
    ]
}
