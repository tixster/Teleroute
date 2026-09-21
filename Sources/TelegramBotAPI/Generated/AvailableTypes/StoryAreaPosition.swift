// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes the position of a clickable area within a story.
public struct StoryAreaPosition: Codable, Hashable, Sendable {
    /// The abscissa of the area's center, as a percentage of the media width
    public var xPercentage: Swift.Double

    /// The ordinate of the area's center, as a percentage of the media height
    public var yPercentage: Swift.Double

    /// The width of the area's rectangle, as a percentage of the media width
    public var widthPercentage: Swift.Double

    /// The height of the area's rectangle, as a percentage of the media height
    public var heightPercentage: Swift.Double

    /// The clockwise rotation angle of the rectangle, in degrees; 0-360
    public var rotationAngle: Swift.Double

    /// The radius of the rectangle corner rounding, as a percentage of the media width
    public var cornerRadiusPercentage: Swift.Double

    public init(
        xPercentage: Swift.Double,
        yPercentage: Swift.Double,
        widthPercentage: Swift.Double,
        heightPercentage: Swift.Double,
        rotationAngle: Swift.Double,
        cornerRadiusPercentage: Swift.Double
    ) {
        self.xPercentage = xPercentage
        self.yPercentage = yPercentage
        self.widthPercentage = widthPercentage
        self.heightPercentage = heightPercentage
        self.rotationAngle = rotationAngle
        self.cornerRadiusPercentage = cornerRadiusPercentage
    }

    public enum CodingKeys: String, CodingKey {
        case xPercentage = "x_percentage"
        case yPercentage = "y_percentage"
        case widthPercentage = "width_percentage"
        case heightPercentage = "height_percentage"
        case rotationAngle = "rotation_angle"
        case cornerRadiusPercentage = "corner_radius_percentage"
    }
}
