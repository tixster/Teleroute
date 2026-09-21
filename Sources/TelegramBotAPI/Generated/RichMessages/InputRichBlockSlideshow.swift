// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A slideshow, corresponding to the custom HTML tag `<tg-slideshow>`.
public struct InputRichBlockSlideshow: Codable, Hashable, Sendable {
    /// Type of the block, always “slideshow”
    public var type: RichBlockKind

    /// Elements of the slideshow
    public var blocks: [InputRichBlock]

    /// *Optional*. Caption of the block
    public var caption: RichBlockCaption?

    public init(
        type: RichBlockKind = .slideshow,
        blocks: [InputRichBlock],
        caption: RichBlockCaption? = nil
    ) {
        self.type = type
        self.blocks = blocks
        self.caption = caption
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case blocks
        case caption
    }
}
