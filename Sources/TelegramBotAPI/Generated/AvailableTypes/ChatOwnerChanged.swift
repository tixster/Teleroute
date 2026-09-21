// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a service message about an ownership change in the chat.
public struct ChatOwnerChanged: Codable, Hashable, Sendable {
    private var newOwnerBox: _IndirectBox<User>
    /// The new owner of the chat
    public var newOwner: User {
        get { self.newOwnerBox.value }
        set { self.newOwnerBox = _IndirectBox(newValue) }
    }

    public init(
        newOwner: User
    ) {
        self.newOwnerBox = _IndirectBox(newOwner)
    }

    public enum CodingKeys: String, CodingKey {
        case newOwnerBox = "new_owner"
    }
}
