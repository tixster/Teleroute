// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A custom emoji.
public struct RichTextCustomEmoji: Codable, Hashable, Sendable {
    /// Type of the rich text, always “custom_emoji”
    public var type: RichTextKind

    /// Unique identifier of the custom emoji. Use `getCustomEmojiStickers` to get full
    /// information about the sticker.
    public var customEmojiId: Swift.String

    /// Alternative emoji for the custom emoji
    public var alternativeText: Swift.String

    public init(
        type: RichTextKind = .customEmoji,
        customEmojiId: Swift.String,
        alternativeText: Swift.String
    ) {
        self.type = type
        self.customEmojiId = customEmojiId
        self.alternativeText = alternativeText
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case customEmojiId = "custom_emoji_id"
        case alternativeText = "alternative_text"
    }
}
