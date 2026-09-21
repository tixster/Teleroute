// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A bot command.
public struct RichTextBotCommand: Codable, Hashable, Sendable {
    /// Type of the rich text, always “bot_command”
    public var type: RichTextKind

    /// The text
    public var text: RichText

    /// The bot command
    public var botCommand: Swift.String

    public init(
        type: RichTextKind = .botCommand,
        text: RichText,
        botCommand: Swift.String
    ) {
        self.type = type
        self.text = text
        self.botCommand = botCommand
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
        case botCommand = "bot_command"
    }
}
