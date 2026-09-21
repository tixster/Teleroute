// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a parameter of the inline keyboard button used to automatically
/// authorize a user. It serves as a great replacement for the Telegram Login Widget when the
/// user is coming from Telegram. All the user needs to do is tap/click a button and confirm
/// that they want to log in: Sample bot: [@DiscussBot](https://t.me/discussbot)
public struct LoginUrl: Codable, Hashable, Sendable {
    /// An HTTPS URL to be opened with user authorization data added to the query string when
    /// the button is pressed. If the user refuses to provide authorization data, the original
    /// URL without information about the user will be opened. The data added is the same as
    /// described in Receiving authorization data. **NOTE:** You **must** always check the hash
    /// of the received data to verify the authentication and the integrity of the data as
    /// described in Checking authorization.
    public var url: Swift.String

    /// *Optional*. New text of the button in forwarded messages
    public var forwardText: Swift.String?

    /// *Optional*. Username of a bot, which will be used for user authorization; not supported
    /// in ``RichMessageButton``. See Setting up a bot for more details. If not specified, the
    /// current bot's username will be assumed. The *url*'s domain must be the same as the
    /// domain linked with the bot. See Linking your domain to the bot for more details.
    public var botUsername: Swift.String?

    /// *Optional*. Pass *True* to request the permission for your bot to send messages to the
    /// user
    public var requestWriteAccess: Swift.Bool?

    public init(
        url: Swift.String,
        forwardText: Swift.String? = nil,
        botUsername: Swift.String? = nil,
        requestWriteAccess: Swift.Bool? = nil
    ) {
        self.url = url
        self.forwardText = forwardText
        self.botUsername = botUsername
        self.requestWriteAccess = requestWriteAccess
    }

    public enum CodingKeys: String, CodingKey {
        case url
        case forwardText = "forward_text"
        case botUsername = "bot_username"
        case requestWriteAccess = "request_write_access"
    }
}
