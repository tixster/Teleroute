// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains information about the color scheme for a user's name, message replies
/// and link previews based on a unique gift.
public struct UniqueGiftColors: Codable, Hashable, Sendable {
    /// Custom emoji identifier of the unique gift's model
    public var modelCustomEmojiId: Swift.String

    /// Custom emoji identifier of the unique gift's symbol
    public var symbolCustomEmojiId: Swift.String

    /// Main color used in light themes; RGB format
    public var lightThemeMainColor: Swift.Int64

    /// List of 1-3 additional colors used in light themes; RGB format
    public var lightThemeOtherColors: [Swift.Int64]

    /// Main color used in dark themes; RGB format
    public var darkThemeMainColor: Swift.Int64

    /// List of 1-3 additional colors used in dark themes; RGB format
    public var darkThemeOtherColors: [Swift.Int64]

    public init(
        modelCustomEmojiId: Swift.String,
        symbolCustomEmojiId: Swift.String,
        lightThemeMainColor: Swift.Int64,
        lightThemeOtherColors: [Swift.Int64],
        darkThemeMainColor: Swift.Int64,
        darkThemeOtherColors: [Swift.Int64]
    ) {
        self.modelCustomEmojiId = modelCustomEmojiId
        self.symbolCustomEmojiId = symbolCustomEmojiId
        self.lightThemeMainColor = lightThemeMainColor
        self.lightThemeOtherColors = lightThemeOtherColors
        self.darkThemeMainColor = darkThemeMainColor
        self.darkThemeOtherColors = darkThemeOtherColors
    }

    public enum CodingKeys: String, CodingKey {
        case modelCustomEmojiId = "model_custom_emoji_id"
        case symbolCustomEmojiId = "symbol_custom_emoji_id"
        case lightThemeMainColor = "light_theme_main_color"
        case lightThemeOtherColors = "light_theme_other_colors"
        case darkThemeMainColor = "dark_theme_main_color"
        case darkThemeOtherColors = "dark_theme_other_colors"
    }
}
