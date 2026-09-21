// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a story area pointing to an HTTP or tg:// link. Currently, a story can have up to
/// 3 link areas.
public struct StoryAreaTypeLink: Codable, Hashable, Sendable {
    /// Type of the area, always “link”
    public var type: StoryAreaTypeKind

    /// HTTP or tg:// URL to be opened when the area is clicked
    public var url: Swift.String

    public init(
        type: StoryAreaTypeKind = .link,
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
