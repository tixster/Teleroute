// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains information about the bot that was created to be managed by the current
/// bot.
public struct ManagedBotCreated: Codable, Hashable, Sendable {
    private var botBox: _IndirectBox<User>
    /// Information about the bot. The bot's token can be fetched using the method
    /// `getManagedBotToken`.
    public var bot: User {
        get { self.botBox.value }
        set { self.botBox = _IndirectBox(newValue) }
    }

    public init(
        bot: User
    ) {
        self.botBox = _IndirectBox(bot)
    }

    public enum CodingKeys: String, CodingKey {
        case botBox = "bot"
    }
}
