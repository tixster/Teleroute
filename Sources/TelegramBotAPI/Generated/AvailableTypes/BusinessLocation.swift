// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Contains information about the location of a Telegram Business account.
public struct BusinessLocation: Codable, Hashable, Sendable {
    /// Address of the business
    public var address: Swift.String

    /// *Optional*. Location of the business
    public var location: Location?

    public init(
        address: Swift.String,
        location: Location? = nil
    ) {
        self.address = address
        self.location = location
    }

    public enum CodingKeys: String, CodingKey {
        case address
        case location
    }
}
