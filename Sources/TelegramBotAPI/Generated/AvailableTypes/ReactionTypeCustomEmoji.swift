// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The reaction is based on a custom emoji.
public struct ReactionTypeCustomEmoji: Codable, Hashable, Sendable {
    /// Type of the reaction, always “custom_emoji”
    public var type: ReactionTypeKind

    /// Custom emoji identifier
    public var customEmojiId: Swift.String

    public init(
        type: ReactionTypeKind = .customEmoji,
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
