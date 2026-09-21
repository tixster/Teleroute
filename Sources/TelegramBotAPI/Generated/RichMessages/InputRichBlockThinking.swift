// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A block with a “Thinking…” placeholder, corresponding to the custom HTML tag
/// `<tg-thinking>`. The block may be used only in `sendRichMessageDraft`, therefore it can't be
/// received in messages. See [https://t.me/addemoji/AIActions](https://t.me/addemoji/AIActions)
/// for examples of custom emoji that are recommended for usage in the block.
public struct InputRichBlockThinking: Codable, Hashable, Sendable {
    /// Type of the block, always “thinking”
    public var type: RichBlockKind

    /// Text of the block. See
    /// [https://t.me/addemoji/AIActions](https://t.me/addemoji/AIActions) for examples of
    /// custom emoji that are recommended for usage in the block.
    public var text: RichText

    public init(
        type: RichBlockKind = .thinking,
        text: RichText
    ) {
        self.type = type
        self.text = text
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
    }
}
