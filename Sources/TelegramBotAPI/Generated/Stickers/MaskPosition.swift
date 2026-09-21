// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the position on faces where a mask should be placed by default.
public struct MaskPosition: Codable, Hashable, Sendable {
    /// The part of the face relative to which the mask should be placed. One of “forehead”,
    /// “eyes”, “mouth”, or “chin”.
    public var point: MaskPositionPoint

    /// Shift by X-axis measured in widths of the mask scaled to the face size, from left to
    /// right. For example, choosing -1.0 will place mask just to the left of the default mask
    /// position.
    public var xShift: Swift.Double

    /// Shift by Y-axis measured in heights of the mask scaled to the face size, from top to
    /// bottom. For example, 1.0 will place the mask just below the default mask position.
    public var yShift: Swift.Double

    /// Mask scaling coefficient. For example, 2.0 means double size.
    public var scale: Swift.Double

    public init(
        point: MaskPositionPoint,
        xShift: Swift.Double,
        yShift: Swift.Double,
        scale: Swift.Double
    ) {
        self.point = point
        self.xShift = xShift
        self.yShift = yShift
        self.scale = scale
    }

    public enum CodingKeys: String, CodingKey {
        case point
        case xShift = "x_shift"
        case yShift = "y_shift"
        case scale
    }
}
