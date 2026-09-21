// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a service message about a chat being joined by a user from a community.
public struct CommunityChatJoined: Codable, Hashable, Sendable {
    /// The community from which the chat was joined
    public var community: Community

    public init(
        community: Community
    ) {
        self.community = community
    }

    public enum CodingKeys: String, CodingKey {
        case community
    }
}
