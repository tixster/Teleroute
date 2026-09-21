// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a shipping address.
public struct ShippingAddress: Codable, Hashable, Sendable {
    /// Two-letter [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)
    /// country code
    public var countryCode: Swift.String

    /// State, if applicable
    public var state: Swift.String

    /// City
    public var city: Swift.String

    /// First line for the address
    public var streetLine1: Swift.String

    /// Second line for the address
    public var streetLine2: Swift.String

    /// Address post code
    public var postCode: Swift.String

    public init(
        countryCode: Swift.String,
        state: Swift.String,
        city: Swift.String,
        streetLine1: Swift.String,
        streetLine2: Swift.String,
        postCode: Swift.String
    ) {
        self.countryCode = countryCode
        self.state = state
        self.city = city
        self.streetLine1 = streetLine1
        self.streetLine2 = streetLine2
        self.postCode = postCode
    }

    public enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case state
        case city
        case streetLine1 = "street_line1"
        case streetLine2 = "street_line2"
        case postCode = "post_code"
    }
}
