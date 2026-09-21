// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The background is taken directly from a built-in chat theme.
public struct BackgroundTypeChatTheme: Codable, Hashable, Sendable {
    /// Type of the background, always “chat_theme”
    public var type: BackgroundTypeKind

    /// Name of the chat theme, which is usually an emoji
    public var themeName: Swift.String

    public init(
        type: BackgroundTypeKind = .chatTheme,
        themeName: Swift.String
    ) {
        self.type = type
        self.themeName = themeName
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case themeName = "theme_name"
    }
}
