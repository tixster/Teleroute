// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a withdrawal transaction to the Telegram Ads platform.
public struct TransactionPartnerTelegramAds: Codable, Hashable, Sendable {
    /// Type of the transaction partner, always “telegram_ads”
    public var type: TransactionPartnerKind

    public init(
        type: TransactionPartnerKind = .telegramAds
    ) {
        self.type = type
    }

    public enum CodingKeys: String, CodingKey {
        case type
    }
}
