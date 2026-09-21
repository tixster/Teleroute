// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The withdrawal is in progress.
public struct RevenueWithdrawalStatePending: Codable, Hashable, Sendable {
    /// Type of the state, always “pending”
    public var type: RevenueWithdrawalStateKind

    public init(
        type: RevenueWithdrawalStateKind = .pending
    ) {
        self.type = type
    }

    public enum CodingKeys: String, CodingKey {
        case type
    }
}
