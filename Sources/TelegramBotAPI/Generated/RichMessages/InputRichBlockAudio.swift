// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A block with a music file, corresponding to the HTML tag `<audio>`.
public struct InputRichBlockAudio: Codable, Hashable, Sendable {
    /// Type of the block, always “audio”
    public var type: RichBlockKind

    private var audioBox: _IndirectBox<InputMediaAudio>
    /// The audio. Caption is ignored.
    public var audio: InputMediaAudio {
        get { self.audioBox.value }
        set { self.audioBox = _IndirectBox(newValue) }
    }

    /// *Optional*. Caption of the block
    public var caption: RichBlockCaption?

    public init(
        type: RichBlockKind = .audio,
        audio: InputMediaAudio,
        caption: RichBlockCaption? = nil
    ) {
        self.type = type
        self.audioBox = _IndirectBox(audio)
        self.caption = caption
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case audioBox = "audio"
        case caption
    }
}
