// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents one special entity in a text message. For example, hashtags,
/// usernames, URLs, etc.
public struct MessageEntity: Codable, Hashable, Sendable {
    /// Type of the entity. Currently, can be “mention” (`@username`), “hashtag” (`#hashtag` or
    /// `#hashtag@chatusername`), “cashtag” (`$USD` or `$USD@chatusername`), “bot_command”
    /// (`/start@jobs_bot`), “url” (`https://telegram.org`), “email”
    /// (`do-not-reply@telegram.org`), “phone_number” (`+1-212-555-0123`), “bold” (**bold
    /// text**), “italic” (*italic text*), “underline” (underlined text), “strikethrough”
    /// (strikethrough text), “spoiler” (spoiler message), “blockquote” (block quotation),
    /// “expandable_blockquote” (collapsed-by-default block quotation), “code” (monowidth
    /// string), “pre” (monowidth block), “text_link” (for clickable text URLs), “text_mention”
    /// (for users [without usernames](https://telegram.org/blog/edit#new-mentions)),
    /// “custom_emoji” (for inline custom emoji stickers), or “date_time” (for formatted date
    /// and time).
    public var type: MessageEntityType

    /// Offset in UTF-16 code units to the start of the entity
    public var offset: Swift.Int64

    /// Length of the entity in UTF-16 code units
    public var length: Swift.Int64

    /// *Optional*. For “text_link” only, URL that will be opened after user taps on the text
    public var url: Swift.String?

    private var userBox: _IndirectBox<User>?
    /// *Optional*. For “text_mention” only, the mentioned user
    public var user: User? {
        get { self.userBox?.value }
        set { self.userBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. For “pre” only, the programming language of the entity text
    public var language: Swift.String?

    /// *Optional*. For “custom_emoji” only, unique identifier of the custom emoji. Use
    /// `getCustomEmojiStickers` to get full information about the sticker.
    public var customEmojiId: Swift.String?

    /// *Optional*. For “date_time” only, the Unix time associated with the entity
    public var unixTime: Swift.Int64?

    /// *Optional*. For “date_time” only, the string that defines the formatting of the date and
    /// time. See date-time entity formatting for more details.
    public var dateTimeFormat: Swift.String?

    public init(
        type: MessageEntityType,
        offset: Swift.Int64,
        length: Swift.Int64,
        url: Swift.String? = nil,
        user: User? = nil,
        language: Swift.String? = nil,
        customEmojiId: Swift.String? = nil,
        unixTime: Swift.Int64? = nil,
        dateTimeFormat: Swift.String? = nil
    ) {
        self.type = type
        self.offset = offset
        self.length = length
        self.url = url
        self.userBox = user.map(_IndirectBox.init)
        self.language = language
        self.customEmojiId = customEmojiId
        self.unixTime = unixTime
        self.dateTimeFormat = dateTimeFormat
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case offset
        case length
        case url
        case userBox = "user"
        case language
        case customEmojiId = "custom_emoji_id"
        case unixTime = "unix_time"
        case dateTimeFormat = "date_time_format"
    }
}
