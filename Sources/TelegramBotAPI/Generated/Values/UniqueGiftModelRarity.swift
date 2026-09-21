// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// *Optional*. Rarity of the model if it is a crafted model. Currently, can be “uncommon”,
/// “rare”, “epic”, or “legendary”.
public enum UniqueGiftModelRarity: RawRepresentable, Codable, Hashable, Sendable {
    case uncommon
    case rare
    case epic
    case legendary
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .uncommon: "uncommon"
        case .rare: "rare"
        case .epic: "epic"
        case .legendary: "legendary"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "uncommon": self = .uncommon
        case "rare": self = .rare
        case "epic": self = .epic
        case "legendary": self = .legendary
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
    public static let documentedCases: [UniqueGiftModelRarity] = [
        .uncommon,
        .rare,
        .epic,
        .legendary,
    ]
}
