// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes an amount of Telegram Stars.
public struct StarAmount: Codable, Hashable, Sendable {
    /// Integer amount of Telegram Stars, rounded to 0; can be negative
    public var amount: Swift.Int64

    /// *Optional*. The number of 1/1000000000 shares of Telegram Stars; from -999999999 to
    /// 999999999; can be negative if and only if *amount* is non-positive
    public var nanostarAmount: Swift.Int64?

    public init(
        amount: Swift.Int64,
        nanostarAmount: Swift.Int64? = nil
    ) {
        self.amount = amount
        self.nanostarAmount = nanostarAmount
    }

    public enum CodingKeys: String, CodingKey {
        case amount
        case nanostarAmount = "nanostar_amount"
    }
}
