// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a bot command.
public struct BotCommand: Codable, Hashable, Sendable {
    /// Text of the command; 1-32 characters. Can contain only lowercase English letters, digits
    /// and underscores.
    public var command: Swift.String

    /// Description of the command; 1-256 characters
    public var description: Swift.String

    /// *Optional*. *True*, if the command sends an ephemeral message, which can be seen only by
    /// the sender of the message and the bot
    public var isEphemeral: Swift.Bool?

    public init(
        command: Swift.String,
        description: Swift.String,
        isEphemeral: Swift.Bool? = nil
    ) {
        self.command = command
        self.description = description
        self.isEphemeral = isEphemeral
    }

    public enum CodingKeys: String, CodingKey {
        case command
        case description
        case isEphemeral = "is_ephemeral"
    }
}
