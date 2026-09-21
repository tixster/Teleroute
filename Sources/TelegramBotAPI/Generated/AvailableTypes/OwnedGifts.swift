// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Contains the list of gifts received and owned by a user or a chat.
public struct OwnedGifts: Codable, Hashable, Sendable {
    /// The total number of gifts owned by the user or the chat
    public var totalCount: Swift.Int64

    /// The list of gifts
    public var gifts: [OwnedGift]

    /// *Optional*. Offset for the next request. If empty, then there are no more results.
    public var nextOffset: Swift.String?

    public init(
        totalCount: Swift.Int64,
        gifts: [OwnedGift],
        nextOffset: Swift.String? = nil
    ) {
        self.totalCount = totalCount
        self.gifts = gifts
        self.nextOffset = nextOffset
    }

    public enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case gifts
        case nextOffset = "next_offset"
    }
}
