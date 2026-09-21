// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains information about the users whose identifiers were shared with the bot
/// using a ``KeyboardButtonRequestUsers`` button.
public struct UsersShared: Codable, Hashable, Sendable {
    /// Identifier of the request
    public var requestId: Swift.Int64

    /// Information about users shared with the bot
    public var users: [SharedUser]

    public init(
        requestId: Swift.Int64,
        users: [SharedUser]
    ) {
        self.requestId = requestId
        self.users = users
    }

    public enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case users
    }
}
