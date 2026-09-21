// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a reaction added to a message along with the number of times it was added.
public struct ReactionCount: Codable, Hashable, Sendable {
    /// Type of the reaction
    public var type: ReactionType

    /// Number of times the reaction was added
    public var totalCount: Swift.Int64

    public init(
        type: ReactionType,
        totalCount: Swift.Int64
    ) {
        self.type = type
        self.totalCount = totalCount
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case totalCount = "total_count"
    }
}
