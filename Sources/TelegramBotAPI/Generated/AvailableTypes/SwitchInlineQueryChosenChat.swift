// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents an inline button that switches the current user to inline mode in a
/// chosen chat, with an optional default inline query.
public struct SwitchInlineQueryChosenChat: Codable, Hashable, Sendable {
    /// *Optional*. The default inline query to be inserted in the input field. If left empty,
    /// only the bot's username will be inserted.
    public var query: Swift.String?

    /// *Optional*. *True*, if private chats with users can be chosen
    public var allowUserChats: Swift.Bool?

    /// *Optional*. *True*, if private chats with bots can be chosen
    public var allowBotChats: Swift.Bool?

    /// *Optional*. *True*, if group and supergroup chats can be chosen
    public var allowGroupChats: Swift.Bool?

    /// *Optional*. *True*, if channel chats can be chosen
    public var allowChannelChats: Swift.Bool?

    public init(
        query: Swift.String? = nil,
        allowUserChats: Swift.Bool? = nil,
        allowBotChats: Swift.Bool? = nil,
        allowGroupChats: Swift.Bool? = nil,
        allowChannelChats: Swift.Bool? = nil
    ) {
        self.query = query
        self.allowUserChats = allowUserChats
        self.allowBotChats = allowBotChats
        self.allowGroupChats = allowGroupChats
        self.allowChannelChats = allowChannelChats
    }

    public enum CodingKeys: String, CodingKey {
        case query
        case allowUserChats = "allow_user_chats"
        case allowBotChats = "allow_bot_chats"
        case allowGroupChats = "allow_group_chats"
        case allowChannelChats = "allow_channel_chats"
    }
}
