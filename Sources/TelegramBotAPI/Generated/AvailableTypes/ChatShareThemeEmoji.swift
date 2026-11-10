// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The theme with emoji placed on a background.
public struct ChatShareThemeEmoji: Codable, Hashable, Sendable {
    /// Type of the theme, always “emoji”
    public var type: ChatShareThemeKind

    /// The emoji; 0-6 regular or custom emoji
    public var emojis: [EmojiType]

    /// *Optional*. Identifier of the backdrop used as the background; omitted if the default
    /// background is used. Use `getChatShareThemeBackdrops` to get details about the backdrop.
    public var backgroundBackdropId: Swift.Int64?

    public init(
        type: ChatShareThemeKind = .emoji,
        emojis: [EmojiType],
        backgroundBackdropId: Swift.Int64? = nil
    ) {
        self.type = type
        self.emojis = emojis
        self.backgroundBackdropId = backgroundBackdropId
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case emojis
        case backgroundBackdropId = "background_backdrop_id"
    }
}
