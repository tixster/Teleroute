// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A block with a photo, corresponding to the HTML tag `<img>`.
public struct InputRichBlockPhoto: Codable, Hashable, Sendable {
    /// Type of the block, always “photo”
    public var type: RichBlockKind

    private var photoBox: _IndirectBox<InputMediaPhoto>
    /// The photo. Caption is ignored.
    public var photo: InputMediaPhoto {
        get { self.photoBox.value }
        set { self.photoBox = _IndirectBox(newValue) }
    }

    /// *Optional*. Caption of the block
    public var caption: RichBlockCaption?

    public init(
        type: RichBlockKind = .photo,
        photo: InputMediaPhoto,
        caption: RichBlockCaption? = nil
    ) {
        self.type = type
        self.photoBox = _IndirectBox(photo)
        self.caption = caption
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case photoBox = "photo"
        case caption
    }
}
