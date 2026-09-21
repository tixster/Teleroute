// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents an HTTP link to be sent.
public struct InputMediaLink: Codable, Hashable, Sendable {
    /// Type of the media, must be *link*
    public var type: InputPollOptionMediaKind

    /// HTTP URL of the link
    public var url: Swift.String

    public init(
        type: InputPollOptionMediaKind = .link,
        url: Swift.String
    ) {
        self.type = type
        self.url = url
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case url
    }
}
