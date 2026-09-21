// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The `type` a ``StoryAreaType`` variant carries.
public enum StoryAreaTypeKind: RawRepresentable, Codable, Hashable, Sendable {
    case location
    case suggestedReaction
    case link
    case weather
    case uniqueGift
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .location: "location"
        case .suggestedReaction: "suggested_reaction"
        case .link: "link"
        case .weather: "weather"
        case .uniqueGift: "unique_gift"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "location": self = .location
        case "suggested_reaction": self = .suggestedReaction
        case "link": self = .link
        case "weather": self = .weather
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
    public static let documentedCases: [StoryAreaTypeKind] = [
        .location,
        .suggestedReaction,
        .link,
        .weather,
        .uniqueGift,
    ]
}
