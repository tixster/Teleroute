// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The theme based on a unique gift owned by the user or the chat.
public struct ChatShareThemeUniqueGift: Codable, Hashable, Sendable {
    /// Type of the theme, always “unique_gift”
    public var type: ChatShareThemeKind

    private var giftBox: _IndirectBox<UniqueGift>
    /// The gift
    public var gift: UniqueGift {
        get { self.giftBox.value }
        set { self.giftBox = _IndirectBox(newValue) }
    }

    public init(
        type: ChatShareThemeKind = .uniqueGift,
        gift: UniqueGift
    ) {
        self.type = type
        self.giftBox = _IndirectBox(gift)
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case giftBox = "gift"
    }
}
