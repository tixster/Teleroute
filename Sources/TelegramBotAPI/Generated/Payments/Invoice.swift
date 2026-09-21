// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains basic information about an invoice.
public struct Invoice: Codable, Hashable, Sendable {
    /// Product name
    public var title: Swift.String

    /// Product description
    public var description: Swift.String

    /// Unique bot deep-linking parameter that can be used to generate this invoice
    public var startParameter: Swift.String

    /// Three-letter ISO 4217 currency code, or “XTR” for payments in [Telegram
    /// Stars](https://t.me/BotNews/90)
    public var currency: Swift.String

    /// Total price in the *smallest units* of the currency (integer, **not** float/double). For
    /// example, for a price of `US$ 1.45` pass `amount = 145`. See the *exp* parameter in
    /// currencies.json, it shows the number of digits past the decimal point for each currency
    /// (2 for the majority of currencies).
    public var totalAmount: Swift.Int64

    public init(
        title: Swift.String,
        description: Swift.String,
        startParameter: Swift.String,
        currency: Swift.String,
        totalAmount: Swift.Int64
    ) {
        self.title = title
        self.description = description
        self.startParameter = startParameter
        self.currency = currency
        self.totalAmount = totalAmount
    }

    public enum CodingKeys: String, CodingKey {
        case title
        case description
        case startParameter = "start_parameter"
        case currency
        case totalAmount = "total_amount"
    }
}
