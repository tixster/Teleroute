// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A divider, corresponding to the HTML tag `<hr/>`.
public struct RichBlockDivider: Codable, Hashable, Sendable {
    /// Type of the block, always “divider”
    public var type: RichBlockKind

    public init(
        type: RichBlockKind = .divider
    ) {
        self.type = type
    }

    public enum CodingKeys: String, CodingKey {
        case type
    }
}
