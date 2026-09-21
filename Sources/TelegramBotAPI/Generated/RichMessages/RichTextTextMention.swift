// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A mention of a Telegram user by their identifier.
public struct RichTextTextMention: Codable, Hashable, Sendable {
    /// Type of the rich text, always “text_mention”
    public var type: RichTextKind

    /// The text
    public var text: RichText

    private var userBox: _IndirectBox<User>
    /// The mentioned user
    public var user: User {
        get { self.userBox.value }
        set { self.userBox = _IndirectBox(newValue) }
    }

    public init(
        type: RichTextKind = .textMention,
        text: RichText,
        user: User
    ) {
        self.type = type
        self.text = text
        self.userBox = _IndirectBox(user)
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
        case userBox = "user"
    }
}
