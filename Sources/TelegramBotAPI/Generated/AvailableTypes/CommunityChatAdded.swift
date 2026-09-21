// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a service message about a chat or a bot being added to a community.
public struct CommunityChatAdded: Codable, Hashable, Sendable {
    /// The new community to which the chat or the bot belongs
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
