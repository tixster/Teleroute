// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents an HTTP link.
public struct Link: Codable, Hashable, Sendable {
    /// URL of the link
    public var url: Swift.String

    public init(
        url: Swift.String
    ) {
        self.url = url
    }

    public enum CodingKeys: String, CodingKey {
        case url
    }
}
