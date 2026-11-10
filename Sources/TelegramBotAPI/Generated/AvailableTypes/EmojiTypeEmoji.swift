// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A regular emoji.
public struct EmojiTypeEmoji: Codable, Hashable, Sendable {
    /// Type of the emoji, always “emoji”
    public var type: EmojiTypeKind

    /// The emoji
    public var emoji: Swift.String

    public init(
        type: EmojiTypeKind = .emoji,
        emoji: Swift.String
    ) {
        self.type = type
        self.emoji = emoji
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case emoji
    }
}
