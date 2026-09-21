// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Rich formatted message.
public struct RichMessage: Codable, Hashable, Sendable {
    /// Content of the message
    public var blocks: [RichBlock]

    /// *Optional*. *True*, if the rich message must be shown right-to-left
    public var isRtl: Swift.Bool?

    public init(
        blocks: [RichBlock],
        isRtl: Swift.Bool? = nil
    ) {
        self.blocks = blocks
        self.isRtl = isRtl
    }

    public enum CodingKeys: String, CodingKey {
        case blocks
        case isRtl = "is_rtl"
    }
}
