// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a game. Use BotFather to create and edit games, their short names
/// will act as unique identifiers.
public struct Game: Codable, Hashable, Sendable {
    /// Title of the game
    public var title: Swift.String

    /// Description of the game
    public var description: Swift.String

    /// Photo that will be displayed in the game message in chats
    public var photo: [PhotoSize]

    /// *Optional*. Brief description of the game or high scores included in the game message.
    /// Can be automatically edited to include current high scores for the game when the bot
    /// calls `setGameScore`, or manually edited using `editMessageText`. 0-4096 characters.
    public var text: Swift.String?

    /// *Optional*. Special entities that appear in *text*, such as usernames, URLs, bot
    /// commands, etc.
    public var textEntities: [MessageEntity]?

    private var animationBox: _IndirectBox<Animation>?
    /// *Optional*. Animation that will be displayed in the game message in chats. Upload via
    /// [BotFather](https://t.me/botfather).
    public var animation: Animation? {
        get { self.animationBox?.value }
        set { self.animationBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        title: Swift.String,
        description: Swift.String,
        photo: [PhotoSize],
        text: Swift.String? = nil,
        textEntities: [MessageEntity]? = nil,
        animation: Animation? = nil
    ) {
        self.title = title
        self.description = description
        self.photo = photo
        self.text = text
        self.textEntities = textEntities
        self.animationBox = animation.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case title
        case description
        case photo
        case text
        case textEntities = "text_entities"
        case animationBox = "animation"
    }
}
