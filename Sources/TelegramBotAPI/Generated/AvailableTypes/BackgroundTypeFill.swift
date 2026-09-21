// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The background is automatically filled based on the selected colors.
public struct BackgroundTypeFill: Codable, Hashable, Sendable {
    /// Type of the background, always “fill”
    public var type: BackgroundTypeKind

    /// The background fill
    public var fill: BackgroundFill

    /// Dimming of the background in dark themes, as a percentage; 0-100
    public var darkThemeDimming: Swift.Int64

    public init(
        type: BackgroundTypeKind = .fill,
        fill: BackgroundFill,
        darkThemeDimming: Swift.Int64
    ) {
        self.type = type
        self.fill = fill
        self.darkThemeDimming = darkThemeDimming
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case fill
        case darkThemeDimming = "dark_theme_dimming"
    }
}
