// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Reason for the refund. Currently, one of “post_deleted” if the post was deleted within 24
/// hours of being posted or removed from scheduled messages without being posted, or
/// “payment_refunded” if the payer refunded their payment.
public enum SuggestedPostRefundedReason: RawRepresentable, Codable, Hashable, Sendable {
    case postDeleted
    case paymentRefunded
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .postDeleted: "post_deleted"
        case .paymentRefunded: "payment_refunded"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "post_deleted": self = .postDeleted
        case "payment_refunded": self = .paymentRefunded
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
    public static let documentedCases: [SuggestedPostRefundedReason] = [
        .postDeleted,
        .paymentRefunded,
    ]
}
