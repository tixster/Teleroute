// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a community (a group of chats).
public struct Community: Codable, Hashable, Sendable {
    /// Unique identifier for this community. This number may have more than 32 significant bits
    /// and some programming languages may have difficulty/silent defects in interpreting it.
    /// But it has at most 52 significant bits, so a signed 64-bit integer or double-precision
    /// float type are safe for storing this identifier.
    public var id: Swift.Int64

    /// Name of the community
    public var name: Swift.String

    public init(
        id: Swift.Int64,
        name: Swift.String
    ) {
        self.id = id
        self.name = name
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
