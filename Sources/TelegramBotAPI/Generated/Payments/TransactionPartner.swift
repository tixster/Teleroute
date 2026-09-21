// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the source of a transaction, or its recipient for outgoing
/// transactions. Currently, it can be one of
public enum TransactionPartner: Codable, Hashable, Sendable {
    case user(TransactionPartnerUser)
    case chat(TransactionPartnerChat)
    case affiliateProgram(TransactionPartnerAffiliateProgram)
    case fragment(TransactionPartnerFragment)
    case telegramAds(TransactionPartnerTelegramAds)
    case telegramApi(TransactionPartnerTelegramApi)
    case other(TransactionPartnerOther)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "user":
            self = .user(try TransactionPartnerUser(from: decoder))
        case "chat":
            self = .chat(try TransactionPartnerChat(from: decoder))
        case "affiliate_program":
            self = .affiliateProgram(try TransactionPartnerAffiliateProgram(from: decoder))
        case "fragment":
            self = .fragment(try TransactionPartnerFragment(from: decoder))
        case "telegram_ads":
            self = .telegramAds(try TransactionPartnerTelegramAds(from: decoder))
        case "telegram_api":
            self = .telegramApi(try TransactionPartnerTelegramApi(from: decoder))
        case "other":
            self = .other(try TransactionPartnerOther(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown TransactionPartner type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .user(value):
            try value.encode(to: encoder)
        case let .chat(value):
            try value.encode(to: encoder)
        case let .affiliateProgram(value):
            try value.encode(to: encoder)
        case let .fragment(value):
            try value.encode(to: encoder)
        case let .telegramAds(value):
            try value.encode(to: encoder)
        case let .telegramApi(value):
            try value.encode(to: encoder)
        case let .other(value):
            try value.encode(to: encoder)
        }
    }
}
