// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Currency in which the payment was made. Currently, one of “XTR” for Telegram Stars or “TON”
/// for TON grams.
///
/// Used by SuggestedPostPaid.currency, SuggestedPostPrice.currency,
/// UniqueGiftInfo.last_resale_currency.
public enum SuggestedPostPaidCurrency: RawRepresentable, Codable, Hashable, Sendable {
    case XTR
    case TON
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .XTR: "XTR"
        case .TON: "TON"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "XTR": self = .XTR
        case "TON": self = .TON
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
    public static let documentedCases: [SuggestedPostPaidCurrency] = [
        .XTR,
        .TON,
    ]
}
