// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// An expandable block for details disclosure, corresponding to the HTML tag `<details>`.
public struct RichBlockDetails: Codable, Hashable, Sendable {
    /// Type of the block, always “details”
    public var type: RichBlockKind

    /// Always shown summary of the block
    public var summary: RichText

    /// Content of the block
    public var blocks: [RichBlock]

    /// *Optional*. *True*, if the content of the block is visible by default
    public var isOpen: Swift.Bool?

    public init(
        type: RichBlockKind = .details,
        summary: RichText,
        blocks: [RichBlock],
        isOpen: Swift.Bool? = nil
    ) {
        self.type = type
        self.summary = summary
        self.blocks = blocks
        self.isOpen = isOpen
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case summary
        case blocks
        case isOpen = "is_open"
    }
}
