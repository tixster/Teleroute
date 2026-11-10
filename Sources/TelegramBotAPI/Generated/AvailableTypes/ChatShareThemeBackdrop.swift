// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes a backdrop, which can be used as the background of a theme of the
/// screen for sharing a link to a user or a chat.
public struct ChatShareThemeBackdrop: Codable, Hashable, Sendable {
    /// Unique identifier of the backdrop
    public var id: Swift.Int64

    /// Name of the backdrop
    public var name: Swift.String

    /// Colors of the backdrop
    public var colors: UniqueGiftBackdropColors

    public init(
        id: Swift.Int64,
        name: Swift.String,
        colors: UniqueGiftBackdropColors
    ) {
        self.id = id
        self.name = name
        self.colors = colors
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case colors
    }
}
