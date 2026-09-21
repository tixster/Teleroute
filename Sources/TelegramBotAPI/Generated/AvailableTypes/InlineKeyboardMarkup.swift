// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents an inline keyboard that appears right next to the message it belongs
/// to.
public struct InlineKeyboardMarkup: Codable, Hashable, Sendable {
    /// Array of button rows, each represented by an Array of ``InlineKeyboardButton`` objects
    public var inlineKeyboard: [[InlineKeyboardButton]]

    /// *Optional*. Pass *True* if the reply interface must be shown to the user, as if they had
    /// manually selected the bot's message and tapped 'Reply'. The value of the field can't be
    /// changed when the inline keyboard is edited.
    public var forceReply: Swift.Bool?

    public init(
        inlineKeyboard: [[InlineKeyboardButton]],
        forceReply: Swift.Bool? = nil
    ) {
        self.inlineKeyboard = inlineKeyboard
        self.forceReply = forceReply
    }

    public enum CodingKeys: String, CodingKey {
        case inlineKeyboard = "inline_keyboard"
        case forceReply = "force_reply"
    }
}
