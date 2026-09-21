// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The background is a wallpaper in the JPEG format.
public struct BackgroundTypeWallpaper: Codable, Hashable, Sendable {
    /// Type of the background, always “wallpaper”
    public var type: BackgroundTypeKind

    private var documentBox: _IndirectBox<Document>
    /// Document with the wallpaper
    public var document: Document {
        get { self.documentBox.value }
        set { self.documentBox = _IndirectBox(newValue) }
    }

    /// Dimming of the background in dark themes, as a percentage; 0-100
    public var darkThemeDimming: Swift.Int64

    /// *Optional*. *True*, if the wallpaper is downscaled to fit in a 450x450 square and then
    /// box-blurred with radius 12
    public var isBlurred: Swift.Bool?

    /// *Optional*. *True*, if the background moves slightly when the device is tilted
    public var isMoving: Swift.Bool?

    public init(
        type: BackgroundTypeKind = .wallpaper,
        document: Document,
        darkThemeDimming: Swift.Int64,
        isBlurred: Swift.Bool? = nil,
        isMoving: Swift.Bool? = nil
    ) {
        self.type = type
        self.documentBox = _IndirectBox(document)
        self.darkThemeDimming = darkThemeDimming
        self.isBlurred = isBlurred
        self.isMoving = isMoving
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case documentBox = "document"
        case darkThemeDimming = "dark_theme_dimming"
        case isBlurred = "is_blurred"
        case isMoving = "is_moving"
    }
}
