// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains information about a user that was shared with the bot using a
/// ``KeyboardButtonRequestUsers`` button.
public struct SharedUser: Codable, Hashable, Sendable {
    /// Identifier of the shared user. This number may have more than 32 significant bits and
    /// some programming languages may have difficulty/silent defects in interpreting it. But it
    /// has at most 52 significant bits, so 64-bit integers or double-precision float types are
    /// safe for storing these identifiers. The bot may not have access to the user and could be
    /// unable to use this identifier, unless the user is already known to the bot by some other
    /// means.
    public var userId: Swift.Int64

    /// *Optional*. First name of the user, if the name was requested by the bot
    public var firstName: Swift.String?

    /// *Optional*. Last name of the user, if the name was requested by the bot
    public var lastName: Swift.String?

    /// *Optional*. Username of the user, if the username was requested by the bot
    public var username: Swift.String?

    /// *Optional*. Available sizes of the chat photo, if the photo was requested by the bot
    public var photo: [PhotoSize]?

    public init(
        userId: Swift.Int64,
        firstName: Swift.String? = nil,
        lastName: Swift.String? = nil,
        username: Swift.String? = nil,
        photo: [PhotoSize]? = nil
    ) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.photo = photo
    }

    public enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case photo
    }
}
