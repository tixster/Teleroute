// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The `source` a ``ChatBoostSource`` variant carries.
public enum ChatBoostSourceKind: RawRepresentable, Codable, Hashable, Sendable {
    case premium
    case giftCode
    case giveaway
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .premium: "premium"
        case .giftCode: "gift_code"
        case .giveaway: "giveaway"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "premium": self = .premium
        case "gift_code": self = .giftCode
        case "giveaway": self = .giveaway
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
    public static let documentedCases: [ChatBoostSourceKind] = [
        .premium,
        .giftCode,
        .giveaway,
    ]
}
