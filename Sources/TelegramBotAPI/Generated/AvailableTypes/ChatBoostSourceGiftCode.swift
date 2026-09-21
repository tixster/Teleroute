// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The boost was obtained by the creation of Telegram Premium gift codes to boost a chat. Each
/// such code boosts the chat 4 times for the duration of the corresponding Telegram Premium
/// subscription.
public struct ChatBoostSourceGiftCode: Codable, Hashable, Sendable {
    /// Source of the boost, always “gift_code”
    public var source: ChatBoostSourceKind

    private var userBox: _IndirectBox<User>
    /// User for which the gift code was created
    public var user: User {
        get { self.userBox.value }
        set { self.userBox = _IndirectBox(newValue) }
    }

    public init(
        source: ChatBoostSourceKind = .giftCode,
        user: User
    ) {
        self.source = source
        self.userBox = _IndirectBox(user)
    }

    public enum CodingKeys: String, CodingKey {
        case source
        case userBox = "user"
    }
}
