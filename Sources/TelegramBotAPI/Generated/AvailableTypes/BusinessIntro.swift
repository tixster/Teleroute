// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Contains information about the start page settings of a Telegram Business account.
public struct BusinessIntro: Codable, Hashable, Sendable {
    /// *Optional*. Title text of the business intro
    public var title: Swift.String?

    /// *Optional*. Message text of the business intro
    public var message: Swift.String?

    private var stickerBox: _IndirectBox<Sticker>?
    /// *Optional*. Sticker of the business intro
    public var sticker: Sticker? {
        get { self.stickerBox?.value }
        set { self.stickerBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        title: Swift.String? = nil,
        message: Swift.String? = nil,
        sticker: Sticker? = nil
    ) {
        self.title = title
        self.message = message
        self.stickerBox = sticker.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case title
        case message
        case stickerBox = "sticker"
    }
}
