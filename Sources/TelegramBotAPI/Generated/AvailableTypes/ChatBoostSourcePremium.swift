// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The boost was obtained by subscribing to Telegram Premium or by gifting a Telegram Premium
/// subscription to another user.
public struct ChatBoostSourcePremium: Codable, Hashable, Sendable {
    /// Source of the boost, always “premium”
    public var source: ChatBoostSourceKind

    private var userBox: _IndirectBox<User>
    /// User that boosted the chat
    public var user: User {
        get { self.userBox.value }
        set { self.userBox = _IndirectBox(newValue) }
    }

    public init(
        source: ChatBoostSourceKind = .premium,
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
