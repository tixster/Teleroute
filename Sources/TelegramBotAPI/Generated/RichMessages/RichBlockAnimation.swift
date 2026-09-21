// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A block with an animation, corresponding to the HTML tag `<video>`.
public struct RichBlockAnimation: Codable, Hashable, Sendable {
    /// Type of the block, always “animation”
    public var type: RichBlockKind

    private var animationBox: _IndirectBox<Animation>
    /// The animation
    public var animation: Animation {
        get { self.animationBox.value }
        set { self.animationBox = _IndirectBox(newValue) }
    }

    /// *Optional*. *True*, if the media preview is covered by a spoiler animation
    public var hasSpoiler: Swift.Bool?

    /// *Optional*. Caption of the block
    public var caption: RichBlockCaption?

    public init(
        type: RichBlockKind = .animation,
        animation: Animation,
        hasSpoiler: Swift.Bool? = nil,
        caption: RichBlockCaption? = nil
    ) {
        self.type = type
        self.animationBox = _IndirectBox(animation)
        self.hasSpoiler = hasSpoiler
        self.caption = caption
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case animationBox = "animation"
        case hasSpoiler = "has_spoiler"
        case caption
    }
}
