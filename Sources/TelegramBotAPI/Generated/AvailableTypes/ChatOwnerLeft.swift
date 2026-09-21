// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a service message about the chat owner leaving the chat.
public struct ChatOwnerLeft: Codable, Hashable, Sendable {
    private var newOwnerBox: _IndirectBox<User>?
    /// *Optional*. The user who will become the new owner of the chat if the previous owner
    /// does not return to the chat
    public var newOwner: User? {
        get { self.newOwnerBox?.value }
        set { self.newOwnerBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        newOwner: User? = nil
    ) {
        self.newOwnerBox = newOwner.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case newOwnerBox = "new_owner"
    }
}
