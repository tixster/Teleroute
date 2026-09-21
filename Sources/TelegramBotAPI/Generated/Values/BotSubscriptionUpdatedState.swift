// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The new state of the subscription. Currently, it can be one of “canceled” if the user
/// canceled the subscription, “active” if the user re-enabled a previously canceled
/// subscription, or “failed” if payment for the subscription failed.
public enum BotSubscriptionUpdatedState: RawRepresentable, Codable, Hashable, Sendable {
    case canceled
    case active
    case failed
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .canceled: "canceled"
        case .active: "active"
        case .failed: "failed"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "canceled": self = .canceled
        case "active": self = .active
        case "failed": self = .failed
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
    public static let documentedCases: [BotSubscriptionUpdatedState] = [
        .canceled,
        .active,
        .failed,
    ]
}
