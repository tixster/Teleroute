// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains basic information about a refunded payment.
public struct RefundedPayment: Codable, Hashable, Sendable {
    /// Three-letter ISO 4217 currency code, or “XTR” for payments in [Telegram
    /// Stars](https://t.me/BotNews/90). Currently, always “XTR”.
    public var currency: Swift.String

    /// Total refunded price in the *smallest units* of the currency (integer, **not**
    /// float/double). For example, for a price of `US$ 1.45`, `total_amount = 145`. See the
    /// *exp* parameter in currencies.json, it shows the number of digits past the decimal point
    /// for each currency (2 for the majority of currencies).
    public var totalAmount: Swift.Int64

    /// Bot-specified invoice payload
    public var invoicePayload: Swift.String

    /// Telegram payment identifier
    public var telegramPaymentChargeId: Swift.String

    /// *Optional*. Provider payment identifier
    public var providerPaymentChargeId: Swift.String?

    public init(
        currency: Swift.String = "XTR",
        totalAmount: Swift.Int64,
        invoicePayload: Swift.String,
        telegramPaymentChargeId: Swift.String,
        providerPaymentChargeId: Swift.String? = nil
    ) {
        self.currency = currency
        self.totalAmount = totalAmount
        self.invoicePayload = invoicePayload
        self.telegramPaymentChargeId = telegramPaymentChargeId
        self.providerPaymentChargeId = providerPaymentChargeId
    }

    public enum CodingKeys: String, CodingKey {
        case currency
        case totalAmount = "total_amount"
        case invoicePayload = "invoice_payload"
        case telegramPaymentChargeId = "telegram_payment_charge_id"
        case providerPaymentChargeId = "provider_payment_charge_id"
    }
}
