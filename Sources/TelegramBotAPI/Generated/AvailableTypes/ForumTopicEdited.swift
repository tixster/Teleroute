// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a service message about an edited forum topic.
public struct ForumTopicEdited: Codable, Hashable, Sendable {
    /// *Optional*. New name of the topic, if it was edited
    public var name: Swift.String?

    /// *Optional*. New identifier of the custom emoji shown as the topic icon, if it was
    /// edited; an empty string if the icon was removed
    public var iconCustomEmojiId: Swift.String?

    public init(
        name: Swift.String? = nil,
        iconCustomEmojiId: Swift.String? = nil
    ) {
        self.name = name
        self.iconCustomEmojiId = iconCustomEmojiId
    }

    public enum CodingKeys: String, CodingKey {
        case name
        case iconCustomEmojiId = "icon_custom_emoji_id"
    }
}
