// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes the paid media added to a message.
public struct PaidMediaInfo: Codable, Hashable, Sendable {
    /// The number of Telegram Stars that must be paid to buy access to the media
    public var starCount: Swift.Int64

    /// Information about the paid media
    public var paidMedia: [PaidMedia]

    public init(
        starCount: Swift.Int64,
        paidMedia: [PaidMedia]
    ) {
        self.starCount = starCount
        self.paidMedia = paidMedia
    }

    public enum CodingKeys: String, CodingKey {
        case starCount = "star_count"
        case paidMedia = "paid_media"
    }
}
