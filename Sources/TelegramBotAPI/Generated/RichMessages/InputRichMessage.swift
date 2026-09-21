// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a rich message to be sent. Exactly **one** of the fields *html*, *markdown*, or
/// *blocks* must be used.
public struct InputRichMessage: Codable, Hashable, Sendable {
    /// *Optional*. Content of the rich message to send described as a list of blocks
    public var blocks: [InputRichBlock]?

    /// *Optional*. Content of the rich message to send described using HTML formatting. See
    /// rich message formatting options for more details. Use *media* field to specify the media
    /// used in the message.
    public var html: Swift.String?

    /// *Optional*. Content of the rich message to send described using Markdown formatting. See
    /// rich message formatting options for more details. Use *media* field to specify the media
    /// used in the message.
    public var markdown: Swift.String?

    /// *Optional*. List of media that are specified in the *markdown* or *html* fields using
    /// `tg://photo?id=`, `tg://video?id=`, `tg://document?id=`, and `tg://audio?id=` links
    public var media: [InputRichMessageMedia]?

    /// *Optional*. Pass *True* if the rich message must be shown right-to-left
    public var isRtl: Swift.Bool?

    /// *Optional*. Pass *True* to skip automatic detection of entities (e.g., URLs, email
    /// addresses, username mentions, hashtags, cashtags, bot commands, or phone numbers) in the
    /// text
    public var skipEntityDetection: Swift.Bool?

    public init(
        blocks: [InputRichBlock]? = nil,
        html: Swift.String? = nil,
        markdown: Swift.String? = nil,
        media: [InputRichMessageMedia]? = nil,
        isRtl: Swift.Bool? = nil,
        skipEntityDetection: Swift.Bool? = nil
    ) {
        self.blocks = blocks
        self.html = html
        self.markdown = markdown
        self.media = media
        self.isRtl = isRtl
        self.skipEntityDetection = skipEntityDetection
    }

    public enum CodingKeys: String, CodingKey {
        case blocks
        case html
        case markdown
        case media
        case isRtl = "is_rtl"
        case skipEntityDetection = "skip_entity_detection"
    }
}
