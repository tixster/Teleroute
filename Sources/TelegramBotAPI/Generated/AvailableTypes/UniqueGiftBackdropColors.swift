// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the colors of the backdrop of a unique gift.
public struct UniqueGiftBackdropColors: Codable, Hashable, Sendable {
    /// The color in the center of the backdrop in RGB format
    public var centerColor: Swift.Int64

    /// The color on the edges of the backdrop in RGB format
    public var edgeColor: Swift.Int64

    /// The color to be applied to the symbol in RGB format
    public var symbolColor: Swift.Int64

    /// The color for the text on the backdrop in RGB format
    public var textColor: Swift.Int64

    public init(
        centerColor: Swift.Int64,
        edgeColor: Swift.Int64,
        symbolColor: Swift.Int64,
        textColor: Swift.Int64
    ) {
        self.centerColor = centerColor
        self.edgeColor = edgeColor
        self.symbolColor = symbolColor
        self.textColor = textColor
    }

    public enum CodingKeys: String, CodingKey {
        case centerColor = "center_color"
        case edgeColor = "edge_color"
        case symbolColor = "symbol_color"
        case textColor = "text_color"
    }
}
