// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a service message about a change in the price of direct messages sent to a channel
/// chat.
public struct DirectMessagePriceChanged: Codable, Hashable, Sendable {
    /// *True*, if direct messages are enabled for the channel chat; *False* otherwise
    public var areDirectMessagesEnabled: Swift.Bool

    /// *Optional*. The new number of Telegram Stars that must be paid by users for each direct
    /// message sent to the channel. Does not apply to users who have been exempted by
    /// administrators. Defaults to 0.
    public var directMessageStarCount: Swift.Int64?

    public init(
        areDirectMessagesEnabled: Swift.Bool,
        directMessageStarCount: Swift.Int64? = nil
    ) {
        self.areDirectMessagesEnabled = areDirectMessagesEnabled
        self.directMessageStarCount = directMessageStarCount
    }

    public enum CodingKeys: String, CodingKey {
        case areDirectMessagesEnabled = "are_direct_messages_enabled"
        case directMessageStarCount = "direct_message_star_count"
    }
}
