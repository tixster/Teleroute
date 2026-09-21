// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The background is a freeform gradient that rotates after every message in the chat.
public struct BackgroundFillFreeformGradient: Codable, Hashable, Sendable {
    /// Type of the background fill, always “freeform_gradient”
    public var type: BackgroundFillKind

    /// A list of the 3 or 4 base colors that are used to generate the freeform gradient in the
    /// RGB24 format
    public var colors: [Swift.Int64]

    public init(
        type: BackgroundFillKind = .freeformGradient,
        colors: [Swift.Int64]
    ) {
        self.type = type
        self.colors = colors
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case colors
    }
}
