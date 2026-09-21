// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object defines the criteria used to request suitable users. Information about the
/// selected users will be shared with the bot when the corresponding button is pressed. More
/// about requesting users »
public struct KeyboardButtonRequestUsers: Codable, Hashable, Sendable {
    /// Signed 32-bit identifier of the request that will be received back in the
    /// ``UsersShared`` object. Must be unique within the message.
    public var requestId: Swift.Int64

    /// *Optional*. Pass *True* to request bots, pass *False* to request regular users. If not
    /// specified, no additional restrictions are applied.
    public var userIsBot: Swift.Bool?

    /// *Optional*. Pass *True* to request premium users, pass *False* to request non-premium
    /// users. If not specified, no additional restrictions are applied.
    public var userIsPremium: Swift.Bool?

    /// *Optional*. The maximum number of users to be selected; 1-10. Defaults to 1.
    public var maxQuantity: Swift.Int64?

    /// *Optional*. Pass *True* to request the users' first and last names
    public var requestName: Swift.Bool?

    /// *Optional*. Pass *True* to request the users' usernames
    public var requestUsername: Swift.Bool?

    /// *Optional*. Pass *True* to request the users' photos
    public var requestPhoto: Swift.Bool?

    public init(
        requestId: Swift.Int64,
        userIsBot: Swift.Bool? = nil,
        userIsPremium: Swift.Bool? = nil,
        maxQuantity: Swift.Int64? = nil,
        requestName: Swift.Bool? = nil,
        requestUsername: Swift.Bool? = nil,
        requestPhoto: Swift.Bool? = nil
    ) {
        self.requestId = requestId
        self.userIsBot = userIsBot
        self.userIsPremium = userIsPremium
        self.maxQuantity = maxQuantity
        self.requestName = requestName
        self.requestUsername = requestUsername
        self.requestPhoto = requestPhoto
    }

    public enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case userIsBot = "user_is_bot"
        case userIsPremium = "user_is_premium"
        case maxQuantity = "max_quantity"
        case requestName = "request_name"
        case requestUsername = "request_username"
        case requestPhoto = "request_photo"
    }
}
