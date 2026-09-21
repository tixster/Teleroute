// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents an animated emoji that displays a random value.
public struct Dice: Codable, Hashable, Sendable {
    /// Emoji on which the dice throw animation is based
    public var emoji: Swift.String

    /// Value of the dice, 1-6 for “🎲”, “🎯” and “🎳” base emoji, 1-5 for “🏀” and “⚽” base emoji,
    /// 1-64 for “🎰” base emoji
    public var value: Swift.Int64

    public init(
        emoji: Swift.String,
        value: Swift.Int64
    ) {
        self.emoji = emoji
        self.value = value
    }

    public enum CodingKeys: String, CodingKey {
        case emoji
        case value
    }
}
