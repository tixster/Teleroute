// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The background is a gradient fill.
public struct BackgroundFillGradient: Codable, Hashable, Sendable {
    /// Type of the background fill, always “gradient”
    public var type: BackgroundFillKind

    /// Top color of the gradient in the RGB24 format
    public var topColor: Swift.Int64

    /// Bottom color of the gradient in the RGB24 format
    public var bottomColor: Swift.Int64

    /// Clockwise rotation angle of the background fill in degrees; 0-359
    public var rotationAngle: Swift.Int64

    public init(
        type: BackgroundFillKind = .gradient,
        topColor: Swift.Int64,
        bottomColor: Swift.Int64,
        rotationAngle: Swift.Int64
    ) {
        self.type = type
        self.topColor = topColor
        self.bottomColor = bottomColor
        self.rotationAngle = rotationAngle
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case topColor = "top_color"
        case bottomColor = "bottom_color"
        case rotationAngle = "rotation_angle"
    }
}
