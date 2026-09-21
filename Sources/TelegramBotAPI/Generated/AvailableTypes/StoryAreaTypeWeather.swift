// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a story area containing weather information. Currently, a story can have up to 3
/// weather areas.
public struct StoryAreaTypeWeather: Codable, Hashable, Sendable {
    /// Type of the area, always “weather”
    public var type: StoryAreaTypeKind

    /// Temperature, in degree Celsius
    public var temperature: Swift.Double

    /// Emoji representing the weather
    public var emoji: Swift.String

    /// A color of the area background in the ARGB format
    public var backgroundColor: Swift.Int64

    public init(
        type: StoryAreaTypeKind = .weather,
        temperature: Swift.Double,
        emoji: Swift.String,
        backgroundColor: Swift.Int64
    ) {
        self.type = type
        self.temperature = temperature
        self.emoji = emoji
        self.backgroundColor = backgroundColor
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case temperature
        case emoji
        case backgroundColor = "background_color"
    }
}
