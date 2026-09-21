// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Contains parameters of a post that is being suggested by the bot.
public struct SuggestedPostParameters: Codable, Hashable, Sendable {
    /// *Optional*. Proposed price for the post. If the field is omitted, then the post is
    /// unpaid.
    public var price: SuggestedPostPrice?

    /// *Optional*. Proposed send date of the post. If specified, then the date must be between
    /// 300 second and 2678400 seconds (30 days) in the future. If the field is omitted, then
    /// the post can be published at any time within 30 days at the sole discretion of the user
    /// who approves it.
    public var sendDate: Swift.Int64?

    public init(
        price: SuggestedPostPrice? = nil,
        sendDate: Swift.Int64? = nil
    ) {
        self.price = price
        self.sendDate = sendDate
    }

    public enum CodingKeys: String, CodingKey {
        case price
        case sendDate = "send_date"
    }
}
