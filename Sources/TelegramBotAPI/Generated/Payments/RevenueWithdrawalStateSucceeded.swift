// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The withdrawal succeeded.
public struct RevenueWithdrawalStateSucceeded: Codable, Hashable, Sendable {
    /// Type of the state, always “succeeded”
    public var type: RevenueWithdrawalStateKind

    /// Date the withdrawal was completed in Unix time
    public var date: Swift.Int64

    /// An HTTPS URL that can be used to see transaction details
    public var url: Swift.String

    public init(
        type: RevenueWithdrawalStateKind = .succeeded,
        date: Swift.Int64,
        url: Swift.String
    ) {
        self.type = type
        self.date = date
        self.url = url
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case date
        case url
    }
}
