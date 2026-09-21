// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a transaction with payment for paid broadcasting.
public struct TransactionPartnerTelegramApi: Codable, Hashable, Sendable {
    /// Type of the transaction partner, always “telegram_api”
    public var type: TransactionPartnerKind

    /// The number of successful requests that exceeded regular limits and were therefore billed
    public var requestCount: Swift.Int64

    public init(
        type: TransactionPartnerKind = .telegramApi,
        requestCount: Swift.Int64
    ) {
        self.type = type
        self.requestCount = requestCount
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case requestCount = "request_count"
    }
}
