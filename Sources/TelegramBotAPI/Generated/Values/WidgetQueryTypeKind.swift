// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The `type` a ``WidgetQueryType`` variant carries.
public enum WidgetQueryTypeKind: RawRepresentable, Codable, Hashable, Sendable {
    case data
    case signData
    case sentTransaction
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .data: "data"
        case .signData: "sign_data"
        case .sentTransaction: "sent_transaction"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "data": self = .data
        case "sign_data": self = .signData
        case "sent_transaction": self = .sentTransaction
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
    public static let documentedCases: [WidgetQueryTypeKind] = [
        .data,
        .signData,
        .sentTransaction,
    ]
}
