// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents one button of an inline keyboard. Exactly one of the fields other
/// than *text*, *icon_custom_emoji_id*, and *style* must be used to specify the type of the
/// button.
public struct InlineKeyboardButton: Codable, Hashable, Sendable {
    /// Label text on the button
    public var text: Swift.String

    /// *Optional*. Unique identifier of the custom emoji shown before the text of the button.
    /// Can only be used by bots that purchased additional usernames on
    /// [Fragment](https://fragment.com) or in the messages directly sent by the bot to private,
    /// group and supergroup chats if the owner of the bot has a Telegram Premium subscription.
    public var iconCustomEmojiId: Swift.String?

    /// *Optional*. Style of the button. Must be one of “danger” (red), “success” (green) or
    /// “primary” (blue). If omitted, then an app-specific style is used.
    public var style: KeyboardButtonStyle?

    /// *Optional*. HTTP or tg:// URL to be opened when the button is pressed. Links
    /// `tg://user?id=<user_id>` can be used to mention a user by their identifier without using
    /// a username, if this is allowed by their privacy settings.
    public var url: Swift.String?

    /// *Optional*. Data to be sent in a callback query to the bot when the button is pressed,
    /// 1-64 bytes
    public var callbackData: Swift.String?

    /// *Optional*. Description of the Web App that will be launched when the user presses the
    /// button. The Web App will be able to send an arbitrary message on behalf of the user
    /// using the method `answerWebAppQuery`. Available only in private chats between a user and
    /// the bot. Not supported for messages sent on behalf of a business account.
    public var webApp: WebAppInfo?

    /// *Optional*. An HTTPS URL used to automatically authorize the user. Can be used as a
    /// replacement for the Telegram Login Widget. Not supported for ephemeral messages.
    public var loginUrl: LoginUrl?

    /// *Optional*. If set, pressing the button will prompt the user to select one of their
    /// chats, open that chat and insert the bot's username and the specified inline query in
    /// the input field. May be empty, in which case just the bot's username will be inserted.
    /// Not supported for messages sent in channel direct messages chats and on behalf of a
    /// business account.
    public var switchInlineQuery: Swift.String?

    /// *Optional*. If set, pressing the button will insert the bot's username and the specified
    /// inline query in the current chat's input field. May be empty, in which case only the
    /// bot's username will be inserted. This offers a quick way for the user to open your bot
    /// in inline mode in the same chat - good for selecting something from multiple options.
    /// Not supported in channels and for messages sent in channel direct messages chats and on
    /// behalf of a business account.
    public var switchInlineQueryCurrentChat: Swift.String?

    /// *Optional*. If set, pressing the button will prompt the user to select one of their
    /// chats of the specified type, open that chat and insert the bot's username and the
    /// specified inline query in the input field. Not supported for messages sent in channel
    /// direct messages chats and on behalf of a business account.
    public var switchInlineQueryChosenChat: SwitchInlineQueryChosenChat?

    /// *Optional*. Description of the button that copies the specified text to the clipboard
    public var copyText: CopyTextButton?

    /// *Optional*. Description of the game that will be launched when the user presses the
    /// button. **NOTE:** This type of button **must** always be the first button in the first
    /// row.
    public var callbackGame: CallbackGame?

    /// *Optional*. Specify *True*, to send a Pay button. Substrings “⭐” and “XTR” in the
    /// buttons's text will be replaced with a Telegram Star icon. **NOTE:** This type of button
    /// **must** always be the first button in the first row and can only be used in invoice
    /// messages.
    public var pay: Swift.Bool?

    /// *Optional*. If set, then the button is disabled and does nothing
    public var disabled: DisabledButton?

    public init(
        text: Swift.String,
        iconCustomEmojiId: Swift.String? = nil,
        style: KeyboardButtonStyle? = nil,
        url: Swift.String? = nil,
        callbackData: Swift.String? = nil,
        webApp: WebAppInfo? = nil,
        loginUrl: LoginUrl? = nil,
        switchInlineQuery: Swift.String? = nil,
        switchInlineQueryCurrentChat: Swift.String? = nil,
        switchInlineQueryChosenChat: SwitchInlineQueryChosenChat? = nil,
        copyText: CopyTextButton? = nil,
        callbackGame: CallbackGame? = nil,
        pay: Swift.Bool? = nil,
        disabled: DisabledButton? = nil
    ) {
        self.text = text
        self.iconCustomEmojiId = iconCustomEmojiId
        self.style = style
        self.url = url
        self.callbackData = callbackData
        self.webApp = webApp
        self.loginUrl = loginUrl
        self.switchInlineQuery = switchInlineQuery
        self.switchInlineQueryCurrentChat = switchInlineQueryCurrentChat
        self.switchInlineQueryChosenChat = switchInlineQueryChosenChat
        self.copyText = copyText
        self.callbackGame = callbackGame
        self.pay = pay
        self.disabled = disabled
    }

    public enum CodingKeys: String, CodingKey {
        case text
        case iconCustomEmojiId = "icon_custom_emoji_id"
        case style
        case url
        case callbackData = "callback_data"
        case webApp = "web_app"
        case loginUrl = "login_url"
        case switchInlineQuery = "switch_inline_query"
        case switchInlineQueryCurrentChat = "switch_inline_query_current_chat"
        case switchInlineQueryChosenChat = "switch_inline_query_chosen_chat"
        case copyText = "copy_text"
        case callbackGame = "callback_game"
        case pay
        case disabled
    }
}
