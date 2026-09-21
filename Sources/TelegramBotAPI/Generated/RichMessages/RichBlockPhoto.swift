// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A block with a photo, corresponding to the HTML tag `<img>`.
public struct RichBlockPhoto: Codable, Hashable, Sendable {
    /// Type of the block, always “photo”
    public var type: RichBlockKind

    /// Available sizes of the photo
    public var photo: [PhotoSize]

    /// *Optional*. *True*, if the media preview is covered by a spoiler animation
    public var hasSpoiler: Swift.Bool?

    /// *Optional*. Caption of the block
    public var caption: RichBlockCaption?

    public init(
        type: RichBlockKind = .photo,
        photo: [PhotoSize],
        hasSpoiler: Swift.Bool? = nil,
        caption: RichBlockCaption? = nil
    ) {
        self.type = type
        self.photo = photo
        self.hasSpoiler = hasSpoiler
        self.caption = caption
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case photo
        case hasSpoiler = "has_spoiler"
        case caption
    }
}
