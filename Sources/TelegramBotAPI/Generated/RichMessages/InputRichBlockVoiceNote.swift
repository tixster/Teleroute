// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A block with a voice note, corresponding to the HTML tag `<audio>`.
public struct InputRichBlockVoiceNote: Codable, Hashable, Sendable {
    /// Type of the block, always “voice_note”
    public var type: RichBlockKind

    /// The voice note. Caption is ignored.
    public var voiceNote: InputMediaVoiceNote

    /// *Optional*. Caption of the block
    public var caption: RichBlockCaption?

    public init(
        type: RichBlockKind = .voiceNote,
        voiceNote: InputMediaVoiceNote,
        caption: RichBlockCaption? = nil
    ) {
        self.type = type
        self.voiceNote = voiceNote
        self.caption = caption
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case voiceNote = "voice_note"
        case caption
    }
}
