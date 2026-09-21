// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The background is filled using the selected color.
public struct BackgroundFillSolid: Codable, Hashable, Sendable {
    /// Type of the background fill, always “solid”
    public var type: BackgroundFillKind

    /// The color of the background fill in the RGB24 format
    public var color: Swift.Int64

    public init(
        type: BackgroundFillKind = .solid,
        color: Swift.Int64
    ) {
        self.type = type
        self.color = color
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case color
    }
}
