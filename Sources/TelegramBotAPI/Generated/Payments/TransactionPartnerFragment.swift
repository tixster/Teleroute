// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a withdrawal transaction with Fragment.
public struct TransactionPartnerFragment: Codable, Hashable, Sendable {
    /// Type of the transaction partner, always “fragment”
    public var type: TransactionPartnerKind

    /// *Optional*. State of the transaction if the transaction is outgoing
    public var withdrawalState: RevenueWithdrawalState?

    public init(
        type: TransactionPartnerKind = .fragment,
        withdrawalState: RevenueWithdrawalState? = nil
    ) {
        self.type = type
        self.withdrawalState = withdrawalState
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case withdrawalState = "withdrawal_state"
    }
}
