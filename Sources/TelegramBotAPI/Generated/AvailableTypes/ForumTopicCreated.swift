// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a service message about a new forum topic created in the chat.
public struct ForumTopicCreated: Codable, Hashable, Sendable {
    /// Name of the topic
    public var name: Swift.String

    /// Color of the topic icon in RGB format
    public var iconColor: Swift.Int64

    /// *Optional*. Unique identifier of the custom emoji shown as the topic icon
    public var iconCustomEmojiId: Swift.String?

    /// *Optional*. *True*, if the name of the topic wasn't specified explicitly by its creator
    /// and likely needs to be changed by the bot
    public var isNameImplicit: Swift.Bool?

    public init(
        name: Swift.String,
        iconColor: Swift.Int64,
        iconCustomEmojiId: Swift.String? = nil,
        isNameImplicit: Swift.Bool? = nil
    ) {
        self.name = name
        self.iconColor = iconColor
        self.iconCustomEmojiId = iconCustomEmojiId
        self.isNameImplicit = isNameImplicit
    }

    public enum CodingKeys: String, CodingKey {
        case name
        case iconColor = "icon_color"
        case iconCustomEmojiId = "icon_custom_emoji_id"
        case isNameImplicit = "is_name_implicit"
    }
}
