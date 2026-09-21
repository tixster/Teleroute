// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A block quotation, corresponding to the HTML tag `<blockquote>`.
public struct RichBlockBlockQuotation: Codable, Hashable, Sendable {
    /// Type of the block, always “blockquote”
    public var type: RichBlockKind

    /// Content of the block
    public var blocks: [RichBlock]

    /// *Optional*. Credit of the block
    public var credit: RichText?

    public init(
        type: RichBlockKind = .blockquote,
        blocks: [RichBlock],
        credit: RichText? = nil
    ) {
        self.type = type
        self.blocks = blocks
        self.credit = credit
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case blocks
        case credit
    }
}
