// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents information about an order.
public struct OrderInfo: Codable, Hashable, Sendable {
    /// *Optional*. User name
    public var name: Swift.String?

    /// *Optional*. User's phone number
    public var phoneNumber: Swift.String?

    /// *Optional*. User email
    public var email: Swift.String?

    /// *Optional*. User shipping address
    public var shippingAddress: ShippingAddress?

    public init(
        name: Swift.String? = nil,
        phoneNumber: Swift.String? = nil,
        email: Swift.String? = nil,
        shippingAddress: ShippingAddress? = nil
    ) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.shippingAddress = shippingAddress
    }

    public enum CodingKeys: String, CodingKey {
        case name
        case phoneNumber = "phone_number"
        case email
        case shippingAddress = "shipping_address"
    }
}
