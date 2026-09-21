// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The message was originally sent by a known user.
public struct MessageOriginUser: Codable, Hashable, Sendable {
    /// Type of the message origin, always “user”
    public var type: MessageOriginKind

    /// Date the message was sent originally in Unix time
    public var date: Swift.Int64

    private var senderUserBox: _IndirectBox<User>
    /// User that sent the message originally
    public var senderUser: User {
        get { self.senderUserBox.value }
        set { self.senderUserBox = _IndirectBox(newValue) }
    }

    public init(
        type: MessageOriginKind = .user,
        date: Swift.Int64,
        senderUser: User
    ) {
        self.type = type
        self.date = date
        self.senderUserBox = _IndirectBox(senderUser)
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case date
        case senderUserBox = "sender_user"
    }
}
