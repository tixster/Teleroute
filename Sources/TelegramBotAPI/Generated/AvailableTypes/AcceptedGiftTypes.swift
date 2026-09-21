// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the types of gifts that can be gifted to a user or a chat.
public struct AcceptedGiftTypes: Codable, Hashable, Sendable {
    /// *True*, if unlimited regular gifts are accepted
    public var unlimitedGifts: Swift.Bool

    /// *True*, if limited regular gifts are accepted
    public var limitedGifts: Swift.Bool

    /// *True*, if unique gifts or gifts that can be upgraded to unique for free are accepted
    public var uniqueGifts: Swift.Bool

    /// *True*, if a Telegram Premium subscription is accepted
    public var premiumSubscription: Swift.Bool

    /// *True*, if transfers of unique gifts from channels are accepted
    public var giftsFromChannels: Swift.Bool

    public init(
        unlimitedGifts: Swift.Bool,
        limitedGifts: Swift.Bool,
        uniqueGifts: Swift.Bool,
        premiumSubscription: Swift.Bool,
        giftsFromChannels: Swift.Bool
    ) {
        self.unlimitedGifts = unlimitedGifts
        self.limitedGifts = limitedGifts
        self.uniqueGifts = uniqueGifts
        self.premiumSubscription = premiumSubscription
        self.giftsFromChannels = giftsFromChannels
    }

    public enum CodingKeys: String, CodingKey {
        case unlimitedGifts = "unlimited_gifts"
        case limitedGifts = "limited_gifts"
        case uniqueGifts = "unique_gifts"
        case premiumSubscription = "premium_subscription"
        case giftsFromChannels = "gifts_from_channels"
    }
}
