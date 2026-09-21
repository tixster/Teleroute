// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The message was originally sent by an unknown user.
public struct MessageOriginHiddenUser: Codable, Hashable, Sendable {
    /// Type of the message origin, always “hidden_user”
    public var type: MessageOriginKind

    /// Date the message was sent originally in Unix time
    public var date: Swift.Int64

    /// Name of the user that sent the message originally
    public var senderUserName: Swift.String

    public init(
        type: MessageOriginKind = .hiddenUser,
        date: Swift.Int64,
        senderUserName: Swift.String
    ) {
        self.type = type
        self.date = date
        self.senderUserName = senderUserName
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case date
        case senderUserName = "sender_user_name"
    }
}
