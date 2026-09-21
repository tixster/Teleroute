// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents one button of the reply keyboard. At most one of the fields other
/// than *text*, *icon_custom_emoji_id*, and *style* must be used to specify the type of the
/// button. For simple text buttons, *String* can be used instead of this object to specify the
/// button text.
public struct KeyboardButton: Codable, Hashable, Sendable {
    /// Text of the button. If none of the fields other than *text*, *icon_custom_emoji_id*, and
    /// *style* are used, it will be sent as a message when the button is pressed.
    public var text: Swift.String

    /// *Optional*. Unique identifier of the custom emoji shown before the text of the button.
    /// Can only be used by bots that purchased additional usernames on
    /// [Fragment](https://fragment.com) or in the messages directly sent by the bot to private,
    /// group and supergroup chats if the owner of the bot has a Telegram Premium subscription.
    public var iconCustomEmojiId: Swift.String?

    /// *Optional*. Style of the button. Must be one of “danger” (red), “success” (green) or
    /// “primary” (blue). If omitted, then an app-specific style is used.
    public var style: KeyboardButtonStyle?

    /// *Optional*. If specified, pressing the button will open a list of suitable users.
    /// Identifiers of selected users will be sent to the bot in a “users_shared” service
    /// message. Available in private chats only.
    public var requestUsers: KeyboardButtonRequestUsers?

    private var requestChatBox: _IndirectBox<KeyboardButtonRequestChat>?
    /// *Optional*. If specified, pressing the button will open a list of suitable chats.
    /// Tapping on a chat will send its identifier to the bot in a “chat_shared” service
    /// message. Available in private chats only.
    public var requestChat: KeyboardButtonRequestChat? {
        get { self.requestChatBox?.value }
        set { self.requestChatBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. If specified, pressing the button will ask the user to create and share a
    /// bot that will be managed by the current bot. Available for bots that enabled management
    /// of other bots in the [@BotFather](https://t.me/BotFather) Mini App. Available in private
    /// chats only.
    public var requestManagedBot: KeyboardButtonRequestManagedBot?

    /// *Optional*. If *True*, the user's phone number will be sent as a contact when the button
    /// is pressed. Available in private chats only.
    public var requestContact: Swift.Bool?

    /// *Optional*. If *True*, the user's current location will be sent when the button is
    /// pressed. Available in private chats only.
    public var requestLocation: Swift.Bool?

    /// *Optional*. If specified, the user will be asked to create a poll and send it to the bot
    /// when the button is pressed. Available in private chats only.
    public var requestPoll: KeyboardButtonPollType?

    /// *Optional*. If specified, the described Web App will be launched when the button is
    /// pressed. The Web App will be able to send a “web_app_data” service message. Available in
    /// private chats only.
    public var webApp: WebAppInfo?

    public init(
        text: Swift.String,
        iconCustomEmojiId: Swift.String? = nil,
        style: KeyboardButtonStyle? = nil,
        requestUsers: KeyboardButtonRequestUsers? = nil,
        requestChat: KeyboardButtonRequestChat? = nil,
        requestManagedBot: KeyboardButtonRequestManagedBot? = nil,
        requestContact: Swift.Bool? = nil,
        requestLocation: Swift.Bool? = nil,
        requestPoll: KeyboardButtonPollType? = nil,
        webApp: WebAppInfo? = nil
    ) {
        self.text = text
        self.iconCustomEmojiId = iconCustomEmojiId
        self.style = style
        self.requestUsers = requestUsers
        self.requestChatBox = requestChat.map(_IndirectBox.init)
        self.requestManagedBot = requestManagedBot
        self.requestContact = requestContact
        self.requestLocation = requestLocation
        self.requestPoll = requestPoll
        self.webApp = webApp
    }

    public enum CodingKeys: String, CodingKey {
        case text
        case iconCustomEmojiId = "icon_custom_emoji_id"
        case style
        case requestUsers = "request_users"
        case requestChatBox = "request_chat"
        case requestManagedBot = "request_managed_bot"
        case requestContact = "request_contact"
        case requestLocation = "request_location"
        case requestPoll = "request_poll"
        case webApp = "web_app"
    }
}
