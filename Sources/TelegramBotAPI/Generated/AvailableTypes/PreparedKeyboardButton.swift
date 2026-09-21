// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a keyboard button to be used by a user of a Mini App.
public struct PreparedKeyboardButton: Codable, Hashable, Sendable {
    /// Unique identifier of the keyboard button
    public var id: Swift.String

    public init(
        id: Swift.String
    ) {
        self.id = id
    }

    public enum CodingKeys: String, CodingKey {
        case id
    }
}
