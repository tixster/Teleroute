// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains a list of backdrops, which can be used as the background of a theme of
/// the screen for sharing a link to a user or a chat.
public struct ChatShareThemeBackdrops: Codable, Hashable, Sendable {
    /// The list of backdrops
    public var backdrops: [ChatShareThemeBackdrop]

    public init(
        backdrops: [ChatShareThemeBackdrop]
    ) {
        self.backdrops = backdrops
    }

    public enum CodingKeys: String, CodingKey {
        case backdrops
    }
}
