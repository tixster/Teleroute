// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes the price of a suggested post.
public struct SuggestedPostPrice: Codable, Hashable, Sendable {
    /// Currency in which the post will be paid. Currently, must be one of “XTR” for Telegram
    /// Stars or “TON” for TON grams.
    public var currency: SuggestedPostPaidCurrency

    /// The amount of the currency that will be paid for the post in the *smallest units* of the
    /// currency, i.e. Telegram Stars or nanograms. Currently, price in Telegram Stars must be
    /// between 5 and 100000, and price in nanograms must be between 10000000 and
    /// 10000000000000.
    public var amount: Swift.Int64

    public init(
        currency: SuggestedPostPaidCurrency,
        amount: Swift.Int64
    ) {
        self.currency = currency
        self.amount = amount
    }

    public enum CodingKeys: String, CodingKey {
        case currency
        case amount
    }
}
