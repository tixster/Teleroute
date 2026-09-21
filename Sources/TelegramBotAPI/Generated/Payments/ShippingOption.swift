// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents one shipping option.
public struct ShippingOption: Codable, Hashable, Sendable {
    /// Shipping option identifier
    public var id: Swift.String

    /// Option title
    public var title: Swift.String

    /// List of price portions
    public var prices: [LabeledPrice]

    public init(
        id: Swift.String,
        title: Swift.String,
        prices: [LabeledPrice]
    ) {
        self.id = id
        self.title = title
        self.prices = prices
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case title
        case prices
    }
}
