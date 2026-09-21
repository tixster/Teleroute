// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains information about an incoming pre-checkout query.
public struct PreCheckoutQuery: Codable, Hashable, Sendable {
    /// Unique query identifier
    public var id: Swift.String

    private var fromBox: _IndirectBox<User>
    /// User who sent the query
    public var from: User {
        get { self.fromBox.value }
        set { self.fromBox = _IndirectBox(newValue) }
    }

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

    /// *Optional*. Identifier of the shipping option chosen by the user
    public var shippingOptionId: Swift.String?

    private var orderInfoBox: _IndirectBox<OrderInfo>?
    /// *Optional*. Order information provided by the user
    public var orderInfo: OrderInfo? {
        get { self.orderInfoBox?.value }
        set { self.orderInfoBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        id: Swift.String,
        from: User,
        currency: Swift.String,
        totalAmount: Swift.Int64,
        invoicePayload: Swift.String,
        shippingOptionId: Swift.String? = nil,
        orderInfo: OrderInfo? = nil
    ) {
        self.id = id
        self.fromBox = _IndirectBox(from)
        self.currency = currency
        self.totalAmount = totalAmount
        self.invoicePayload = invoicePayload
        self.shippingOptionId = shippingOptionId
        self.orderInfoBox = orderInfo.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case fromBox = "from"
        case currency
        case totalAmount = "total_amount"
        case invoicePayload = "invoice_payload"
        case shippingOptionId = "shipping_option_id"
        case orderInfoBox = "order_info"
    }
}
