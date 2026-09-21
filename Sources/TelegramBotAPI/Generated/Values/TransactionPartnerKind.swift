// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The `type` a ``TransactionPartner`` variant carries.
public enum TransactionPartnerKind: RawRepresentable, Codable, Hashable, Sendable {
    case user
    case chat
    case affiliateProgram
    case fragment
    case telegramAds
    case telegramApi
    case other
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .user: "user"
        case .chat: "chat"
        case .affiliateProgram: "affiliate_program"
        case .fragment: "fragment"
        case .telegramAds: "telegram_ads"
        case .telegramApi: "telegram_api"
        case .other: "other"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "user": self = .user
        case "chat": self = .chat
        case "affiliate_program": self = .affiliateProgram
        case "fragment": self = .fragment
        case "telegram_ads": self = .telegramAds
        case "telegram_api": self = .telegramApi
        case "other": self = .other
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
    public static let documentedCases: [TransactionPartnerKind] = [
        .user,
        .chat,
        .affiliateProgram,
        .fragment,
        .telegramAds,
        .telegramApi,
        .other,
    ]
}
