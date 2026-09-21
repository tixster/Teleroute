// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a transaction with an unknown source or recipient.
public struct TransactionPartnerOther: Codable, Hashable, Sendable {
    /// Type of the transaction partner, always “other”
    public var type: TransactionPartnerKind

    public init(
        type: TransactionPartnerKind = .other
    ) {
        self.type = type
    }

    public enum CodingKeys: String, CodingKey {
        case type
    }
}
