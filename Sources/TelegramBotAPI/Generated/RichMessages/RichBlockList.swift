// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A list of blocks, corresponding to the HTML tag `<ul>` or `<ol>` with multiple nested tags
/// `<li>`.
public struct RichBlockList: Codable, Hashable, Sendable {
    /// Type of the block, always “list”
    public var type: RichBlockKind

    /// Items of the list
    public var items: [RichBlockListItem]

    public init(
        type: RichBlockKind = .list,
        items: [RichBlockListItem]
    ) {
        self.type = type
        self.items = items
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case items
    }
}
