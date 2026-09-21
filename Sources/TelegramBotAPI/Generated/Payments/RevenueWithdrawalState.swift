// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the state of a revenue withdrawal operation. Currently, it can be one
/// of
public enum RevenueWithdrawalState: Codable, Hashable, Sendable {
    case pending(RevenueWithdrawalStatePending)
    case succeeded(RevenueWithdrawalStateSucceeded)
    case failed(RevenueWithdrawalStateFailed)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "pending":
            self = .pending(try RevenueWithdrawalStatePending(from: decoder))
        case "succeeded":
            self = .succeeded(try RevenueWithdrawalStateSucceeded(from: decoder))
        case "failed":
            self = .failed(try RevenueWithdrawalStateFailed(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown RevenueWithdrawalState type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .pending(value):
            try value.encode(to: encoder)
        case let .succeeded(value):
            try value.encode(to: encoder)
        case let .failed(value):
            try value.encode(to: encoder)
        }
    }
}
