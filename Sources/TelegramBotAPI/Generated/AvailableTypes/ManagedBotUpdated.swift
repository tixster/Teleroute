// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains information about the creation, token update, or owner update of a bot
/// that is managed by the current bot.
public struct ManagedBotUpdated: Codable, Hashable, Sendable {
    private var userBox: _IndirectBox<User>
    /// User that created the bot
    public var user: User {
        get { self.userBox.value }
        set { self.userBox = _IndirectBox(newValue) }
    }

    private var botBox: _IndirectBox<User>
    /// Information about the bot. Token of the bot can be fetched using the method
    /// `getManagedBotToken`.
    public var bot: User {
        get { self.botBox.value }
        set { self.botBox = _IndirectBox(newValue) }
    }

    public init(
        user: User,
        bot: User
    ) {
        self.userBox = _IndirectBox(user)
        self.botBox = _IndirectBox(bot)
    }

    public enum CodingKeys: String, CodingKey {
        case userBox = "user"
        case botBox = "bot"
    }
}
