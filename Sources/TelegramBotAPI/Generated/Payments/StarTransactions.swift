// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Contains a list of Telegram Star transactions.
public struct StarTransactions: Codable, Hashable, Sendable {
    /// The list of transactions
    public var transactions: [StarTransaction]

    public init(
        transactions: [StarTransaction]
    ) {
        self.transactions = transactions
    }

    public enum CodingKeys: String, CodingKey {
        case transactions
    }
}
