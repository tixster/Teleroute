// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A custom emoji.
public struct EmojiTypeCustomEmoji: Codable, Hashable, Sendable {
    /// Type of the emoji, always “custom_emoji”
    public var type: EmojiTypeKind

    /// Identifier of the custom emoji. Use `getCustomEmojiStickers` to get full information
    /// about the sticker.
    public var customEmojiId: Swift.String

    public init(
        type: EmojiTypeKind = .customEmoji,
        customEmojiId: Swift.String
    ) {
        self.type = type
        self.customEmojiId = customEmojiId
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case customEmojiId = "custom_emoji_id"
    }
}
