// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains information about an incoming shipping query.
public struct ShippingQuery: Codable, Hashable, Sendable {
    /// Unique query identifier
    public var id: Swift.String

    private var fromBox: _IndirectBox<User>
    /// User who sent the query
    public var from: User {
        get { self.fromBox.value }
        set { self.fromBox = _IndirectBox(newValue) }
    }

    /// Bot-specified invoice payload
    public var invoicePayload: Swift.String

    /// User specified shipping address
    public var shippingAddress: ShippingAddress

    public init(
        id: Swift.String,
        from: User,
        invoicePayload: Swift.String,
        shippingAddress: ShippingAddress
    ) {
        self.id = id
        self.fromBox = _IndirectBox(from)
        self.invoicePayload = invoicePayload
        self.shippingAddress = shippingAddress
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case fromBox = "from"
        case invoicePayload = "invoice_payload"
        case shippingAddress = "shipping_address"
    }
}
