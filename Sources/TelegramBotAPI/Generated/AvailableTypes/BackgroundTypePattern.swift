// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The background is a .PNG or .TGV (gzipped subset of SVG with MIME type
/// “application/x-tgwallpattern”) pattern to be combined with the background fill chosen by the
/// user.
public struct BackgroundTypePattern: Codable, Hashable, Sendable {
    /// Type of the background, always “pattern”
    public var type: BackgroundTypeKind

    private var documentBox: _IndirectBox<Document>
    /// Document with the pattern
    public var document: Document {
        get { self.documentBox.value }
        set { self.documentBox = _IndirectBox(newValue) }
    }

    /// The background fill that is combined with the pattern
    public var fill: BackgroundFill

    /// Intensity of the pattern when it is shown above the filled background; 0-100
    public var intensity: Swift.Int64

    /// *Optional*. *True*, if the background fill must be applied only to the pattern itself.
    /// All other pixels are black in this case. For dark themes only.
    public var isInverted: Swift.Bool?

    /// *Optional*. *True*, if the background moves slightly when the device is tilted
    public var isMoving: Swift.Bool?

    public init(
        type: BackgroundTypeKind = .pattern,
        document: Document,
        fill: BackgroundFill,
        intensity: Swift.Int64,
        isInverted: Swift.Bool? = nil,
        isMoving: Swift.Bool? = nil
    ) {
        self.type = type
        self.documentBox = _IndirectBox(document)
        self.fill = fill
        self.intensity = intensity
        self.isInverted = isInverted
        self.isMoving = isMoving
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case documentBox = "document"
        case fill
        case intensity
        case isInverted = "is_inverted"
        case isMoving = "is_moving"
    }
}
