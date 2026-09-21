// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a contact with a phone number. By default, this contact will be sent by the user.
/// Alternatively, you can use *input_message_content* to send a message with the specified
/// content instead of the contact.
public struct InlineQueryResultContact: Codable, Hashable, Sendable {
    /// Type of the result, must be *contact*
    public var type: InlineQueryResultKind

    /// Unique identifier for this result, 1-64 Bytes
    public var id: Swift.String

    /// Contact's phone number
    public var phoneNumber: Swift.String

    /// Contact's first name
    public var firstName: Swift.String

    /// *Optional*. Contact's last name
    public var lastName: Swift.String?

    /// *Optional*. Additional data about the contact in the form of a
    /// [vCard](https://en.wikipedia.org/wiki/VCard), 0-2048 bytes
    public var vcard: Swift.String?

    /// *Optional*. Inline keyboard attached to the message
    public var replyMarkup: InlineKeyboardMarkup?

    private var inputMessageContentBox: _IndirectBox<InputMessageContent>?
    /// *Optional*. Content of the message to be sent instead of the contact
    public var inputMessageContent: InputMessageContent? {
        get { self.inputMessageContentBox?.value }
        set { self.inputMessageContentBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Url of the thumbnail for the result
    public var thumbnailUrl: Swift.String?

    /// *Optional*. Thumbnail width
    public var thumbnailWidth: Swift.Int64?

    /// *Optional*. Thumbnail height
    public var thumbnailHeight: Swift.Int64?

    public init(
        type: InlineQueryResultKind = .contact,
        id: Swift.String,
        phoneNumber: Swift.String,
        firstName: Swift.String,
        lastName: Swift.String? = nil,
        vcard: Swift.String? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil,
        inputMessageContent: InputMessageContent? = nil,
        thumbnailUrl: Swift.String? = nil,
        thumbnailWidth: Swift.Int64? = nil,
        thumbnailHeight: Swift.Int64? = nil
    ) {
        self.type = type
        self.id = id
        self.phoneNumber = phoneNumber
        self.firstName = firstName
        self.lastName = lastName
        self.vcard = vcard
        self.replyMarkup = replyMarkup
        self.inputMessageContentBox = inputMessageContent.map(_IndirectBox.init)
        self.thumbnailUrl = thumbnailUrl
        self.thumbnailWidth = thumbnailWidth
        self.thumbnailHeight = thumbnailHeight
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case id
        case phoneNumber = "phone_number"
        case firstName = "first_name"
        case lastName = "last_name"
        case vcard
        case replyMarkup = "reply_markup"
        case inputMessageContentBox = "input_message_content"
        case thumbnailUrl = "thumbnail_url"
        case thumbnailWidth = "thumbnail_width"
        case thumbnailHeight = "thumbnail_height"
    }
}
