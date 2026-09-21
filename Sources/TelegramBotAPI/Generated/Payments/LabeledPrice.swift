// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a portion of the price for goods or services.
public struct LabeledPrice: Codable, Hashable, Sendable {
    /// Portion label
    public var label: Swift.String

    /// Price of the product in the *smallest units* of the currency (integer, **not**
    /// float/double). For example, for a price of `US$ 1.45` pass `amount = 145`. See the *exp*
    /// parameter in currencies.json, it shows the number of digits past the decimal point for
    /// each currency (2 for the majority of currencies).
    public var amount: Swift.Int64

    public init(
        label: Swift.String,
        amount: Swift.Int64
    ) {
        self.label = label
        self.amount = amount
    }

    public enum CodingKeys: String, CodingKey {
        case label
        case amount
    }
}
