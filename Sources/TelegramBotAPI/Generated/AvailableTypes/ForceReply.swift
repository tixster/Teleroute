// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Upon receiving a message with this object, Telegram clients will display a reply interface
/// to the user (act as if the user has selected the bot's message and tapped 'Reply'). This can
/// be extremely useful if you want to create user-friendly step-by-step interfaces without
/// having to sacrifice privacy mode. Not supported in channels and for messages sent on behalf
/// of a user account.
public struct ForceReply: Codable, Hashable, Sendable {
    /// Shows reply interface to the user, as if they had manually selected the bot's message
    /// and tapped 'Reply'
    public var forceReply: Swift.Bool

    /// *Optional*. The placeholder to be shown in the input field when the reply is active;
    /// 1-64 characters
    public var inputFieldPlaceholder: Swift.String?

    /// *Optional*. Use this parameter if you want to force reply from specific users only.
    /// Targets: 1) users that are @mentioned in the *text* of the ``Message`` object; 2) if the
    /// bot's message is a reply to a message in the same chat and forum topic, sender of the
    /// original message.
    public var selective: Swift.Bool?

    public init(
        forceReply: Swift.Bool,
        inputFieldPlaceholder: Swift.String? = nil,
        selective: Swift.Bool? = nil
    ) {
        self.forceReply = forceReply
        self.inputFieldPlaceholder = inputFieldPlaceholder
        self.selective = selective
    }

    public enum CodingKeys: String, CodingKey {
        case forceReply = "force_reply"
        case inputFieldPlaceholder = "input_field_placeholder"
        case selective
    }
}
