// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// State of the suggested post. Currently, it can be one of “pending”, “approved”, “declined”.
public enum SuggestedPostInfoState: RawRepresentable, Codable, Hashable, Sendable {
    case pending
    case approved
    case declined
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .pending: "pending"
        case .approved: "approved"
        case .declined: "declined"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "pending": self = .pending
        case "approved": self = .approved
        case "declined": self = .declined
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
    public static let documentedCases: [SuggestedPostInfoState] = [
        .pending,
        .approved,
        .declined,
    ]
}
