// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a location to which a chat is connected.
public struct ChatLocation: Codable, Hashable, Sendable {
    /// The location to which the supergroup is connected. Can't be a live location.
    public var location: Location

    /// Location address; 1-64 characters, as defined by the chat owner
    public var address: Swift.String

    public init(
        location: Location,
        address: Swift.String
    ) {
        self.location = location
        self.address = address
    }

    public enum CodingKeys: String, CodingKey {
        case location
        case address
    }
}
