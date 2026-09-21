// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A quotation with centered text, loosely corresponding to the HTML tag `<aside>`.
public struct RichBlockPullQuotation: Codable, Hashable, Sendable {
    /// Type of the block, always “pullquote”
    public var type: RichBlockKind

    /// Text of the block
    public var text: RichText

    /// *Optional*. Credit of the block
    public var credit: RichText?

    public init(
        type: RichBlockKind = .pullquote,
        text: RichText,
        credit: RichText? = nil
    ) {
        self.type = type
        self.text = text
        self.credit = credit
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
        case credit
    }
}
