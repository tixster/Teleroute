// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains basic information about a successful payment. Note that if the buyer
/// initiates a chargeback with the relevant payment provider following this transaction, the
/// funds may be debited from your balance. This is outside of Telegram's control.
public struct SuccessfulPayment: Codable, Hashable, Sendable {
    /// Three-letter ISO 4217 currency code, or “XTR” for payments in [Telegram
    /// Stars](https://t.me/BotNews/90)
    public var currency: Swift.String

    /// Total price in the *smallest units* of the currency (integer, **not** float/double). For
    /// example, for a price of `US$ 1.45` pass `amount = 145`. See the *exp* parameter in
    /// currencies.json, it shows the number of digits past the decimal point for each currency
    /// (2 for the majority of currencies).
    public var totalAmount: Swift.Int64

    /// Bot-specified invoice payload
    public var invoicePayload: Swift.String

    /// *Optional*. Expiration date of the subscription, in Unix time; for recurring payments
    /// only
    public var subscriptionExpirationDate: Swift.Int64?

    /// *Optional*. *True*, if the payment is a recurring payment for a subscription
    public var isRecurring: Swift.Bool?

    /// *Optional*. *True*, if the payment is the first payment for a subscription
    public var isFirstRecurring: Swift.Bool?

    /// *Optional*. Identifier of the shipping option chosen by the user
    public var shippingOptionId: Swift.String?

    private var orderInfoBox: _IndirectBox<OrderInfo>?
    /// *Optional*. Order information provided by the user
    public var orderInfo: OrderInfo? {
        get { self.orderInfoBox?.value }
        set { self.orderInfoBox = newValue.map(_IndirectBox.init) }
    }

    /// Telegram payment identifier
    public var telegramPaymentChargeId: Swift.String

    /// Provider payment identifier
    public var providerPaymentChargeId: Swift.String

    public init(
        currency: Swift.String,
        totalAmount: Swift.Int64,
        invoicePayload: Swift.String,
        subscriptionExpirationDate: Swift.Int64? = nil,
        isRecurring: Swift.Bool? = nil,
        isFirstRecurring: Swift.Bool? = nil,
        shippingOptionId: Swift.String? = nil,
        orderInfo: OrderInfo? = nil,
        telegramPaymentChargeId: Swift.String,
        providerPaymentChargeId: Swift.String
    ) {
        self.currency = currency
        self.totalAmount = totalAmount
        self.invoicePayload = invoicePayload
        self.subscriptionExpirationDate = subscriptionExpirationDate
        self.isRecurring = isRecurring
        self.isFirstRecurring = isFirstRecurring
        self.shippingOptionId = shippingOptionId
        self.orderInfoBox = orderInfo.map(_IndirectBox.init)
        self.telegramPaymentChargeId = telegramPaymentChargeId
        self.providerPaymentChargeId = providerPaymentChargeId
    }

    public enum CodingKeys: String, CodingKey {
        case currency
        case totalAmount = "total_amount"
        case invoicePayload = "invoice_payload"
        case subscriptionExpirationDate = "subscription_expiration_date"
        case isRecurring = "is_recurring"
        case isFirstRecurring = "is_first_recurring"
        case shippingOptionId = "shipping_option_id"
        case orderInfoBox = "order_info"
        case telegramPaymentChargeId = "telegram_payment_charge_id"
        case providerPaymentChargeId = "provider_payment_charge_id"
    }
}
