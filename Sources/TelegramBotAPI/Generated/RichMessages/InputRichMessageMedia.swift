// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a media element embedded in an outgoing rich message.
public struct InputRichMessageMedia: Codable, Hashable, Sendable {
    /// Unique identifier of the media used in a `tg://photo?id=`, `tg://video?id=`,
    /// `tg://document?id=`, or `tg://audio?id=` link. 1-64 characters, only `A-Z`, `a-z`,
    /// `0-9`, `_` and `-` are allowed.
    public var id: Swift.String

    private var mediaBox: _IndirectBox<RichMessageInputMedia>
    /// The media to be sent. Everything except the media itself and its properties is ignored.
    public var media: RichMessageInputMedia {
        get { self.mediaBox.value }
        set { self.mediaBox = _IndirectBox(newValue) }
    }

    public init(
        id: Swift.String,
        media: RichMessageInputMedia
    ) {
        self.id = id
        self.mediaBox = _IndirectBox(media)
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case mediaBox = "media"
    }
}
