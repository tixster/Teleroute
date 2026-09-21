// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the background of a gift.
public struct GiftBackground: Codable, Hashable, Sendable {
    /// Center color of the background in RGB format
    public var centerColor: Swift.Int64

    /// Edge color of the background in RGB format
    public var edgeColor: Swift.Int64

    /// Text color of the background in RGB format
    public var textColor: Swift.Int64

    public init(
        centerColor: Swift.Int64,
        edgeColor: Swift.Int64,
        textColor: Swift.Int64
    ) {
        self.centerColor = centerColor
        self.edgeColor = edgeColor
        self.textColor = textColor
    }

    public enum CodingKeys: String, CodingKey {
        case centerColor = "center_color"
        case edgeColor = "edge_color"
        case textColor = "text_color"
    }
}
