// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Contains information about a suggested post.
public struct SuggestedPostInfo: Codable, Hashable, Sendable {
    /// State of the suggested post. Currently, it can be one of “pending”, “approved”,
    /// “declined”.
    public var state: SuggestedPostInfoState

    /// *Optional*. Proposed price of the post. If the field is omitted, then the post is
    /// unpaid.
    public var price: SuggestedPostPrice?

    /// *Optional*. Proposed send date of the post. If the field is omitted, then the post can
    /// be published at any time within 30 days at the sole discretion of the user or
    /// administrator who approves it.
    public var sendDate: Swift.Int64?

    public init(
        state: SuggestedPostInfoState,
        price: SuggestedPostPrice? = nil,
        sendDate: Swift.Int64? = nil
    ) {
        self.state = state
        self.price = price
        self.sendDate = sendDate
    }

    public enum CodingKeys: String, CodingKey {
        case state
        case price
        case sendDate = "send_date"
    }
}
