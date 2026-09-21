// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the source of a chat boost. It can be one of
public enum ChatBoostSource: Codable, Hashable, Sendable {
    case premium(ChatBoostSourcePremium)
    case giftCode(ChatBoostSourceGiftCode)
    case giveaway(ChatBoostSourceGiveaway)

    public enum CodingKeys: String, CodingKey {
        case source
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .source) {
        case "premium":
            self = .premium(try ChatBoostSourcePremium(from: decoder))
        case "gift_code":
            self = .giftCode(try ChatBoostSourceGiftCode(from: decoder))
        case "giveaway":
            self = .giveaway(try ChatBoostSourceGiveaway(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .source, in: container,
                debugDescription: "unknown ChatBoostSource source '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .premium(value):
            try value.encode(to: encoder)
        case let .giftCode(value):
            try value.encode(to: encoder)
        case let .giveaway(value):
            try value.encode(to: encoder)
        }
    }
}
