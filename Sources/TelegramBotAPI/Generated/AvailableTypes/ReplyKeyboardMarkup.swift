// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a custom keyboard with reply options (see Introduction to bots for
/// details and examples). Not supported in channels and for messages sent on behalf of a
/// business account.
public struct ReplyKeyboardMarkup: Codable, Hashable, Sendable {
    /// Array of button rows, each represented by an Array of ``KeyboardButton`` objects
    public var keyboard: [[KeyboardButton]]

    /// *Optional*. Requests clients to always show the keyboard when the regular keyboard is
    /// hidden. Defaults to *False*, in which case the custom keyboard can be hidden and opened
    /// with a keyboard icon.
    public var isPersistent: Swift.Bool?

    /// *Optional*. Requests clients to resize the keyboard vertically for optimal fit (e.g.,
    /// make the keyboard smaller if there are just two rows of buttons). Defaults to *False*,
    /// in which case the custom keyboard is always of the same height as the app's standard
    /// keyboard.
    public var resizeKeyboard: Swift.Bool?

    /// *Optional*. Requests clients to hide the keyboard as soon as it's been used. The
    /// keyboard will still be available, but clients will automatically display the usual
    /// letter-keyboard in the chat - the user can press a special button in the input field to
    /// see the custom keyboard again. Defaults to *False*.
    public var oneTimeKeyboard: Swift.Bool?

    /// *Optional*. The placeholder to be shown in the input field when the keyboard is active;
    /// 1-64 characters
    public var inputFieldPlaceholder: Swift.String?

    /// *Optional*. Use this parameter if you want to show the keyboard to specific users only.
    /// Targets: 1) users that are @mentioned in the *text* of the ``Message`` object; 2) if the
    /// bot's message is a reply to a message in the same chat and forum topic, sender of the
    /// original message. *Example:* A user requests to change the bot's language, bot replies
    /// to the request with a keyboard to select the new language. Other users in the group
    /// don't see the keyboard.
    public var selective: Swift.Bool?

    /// *Optional*. Pass *True* if the reply interface must be shown to the user, as if they had
    /// manually selected the bot's message and tapped 'Reply'
    public var forceReply: Swift.Bool?

    public init(
        keyboard: [[KeyboardButton]],
        isPersistent: Swift.Bool? = nil,
        resizeKeyboard: Swift.Bool? = nil,
        oneTimeKeyboard: Swift.Bool? = nil,
        inputFieldPlaceholder: Swift.String? = nil,
        selective: Swift.Bool? = nil,
        forceReply: Swift.Bool? = nil
    ) {
        self.keyboard = keyboard
        self.isPersistent = isPersistent
        self.resizeKeyboard = resizeKeyboard
        self.oneTimeKeyboard = oneTimeKeyboard
        self.inputFieldPlaceholder = inputFieldPlaceholder
        self.selective = selective
        self.forceReply = forceReply
    }

    public enum CodingKeys: String, CodingKey {
        case keyboard
        case isPersistent = "is_persistent"
        case resizeKeyboard = "resize_keyboard"
        case oneTimeKeyboard = "one_time_keyboard"
        case inputFieldPlaceholder = "input_field_placeholder"
        case selective
        case forceReply = "force_reply"
    }
}
