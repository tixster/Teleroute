// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes the physical address of a location.
public struct LocationAddress: Codable, Hashable, Sendable {
    /// The two-letter ISO 3166-1 alpha-2 country code of the country where the location is
    /// located
    public var countryCode: Swift.String

    /// *Optional*. State of the location
    public var state: Swift.String?

    /// *Optional*. City of the location
    public var city: Swift.String?

    /// *Optional*. Street address of the location
    public var street: Swift.String?

    public init(
        countryCode: Swift.String,
        state: Swift.String? = nil,
        city: Swift.String? = nil,
        street: Swift.String? = nil
    ) {
        self.countryCode = countryCode
        self.state = state
        self.city = city
        self.street = street
    }

    public enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case state
        case city
        case street
    }
}
