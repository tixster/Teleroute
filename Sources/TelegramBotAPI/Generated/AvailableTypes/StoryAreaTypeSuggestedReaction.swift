// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a story area pointing to a suggested reaction. Currently, a story can have up to 5
/// suggested reaction areas.
public struct StoryAreaTypeSuggestedReaction: Codable, Hashable, Sendable {
    /// Type of the area, always “suggested_reaction”
    public var type: StoryAreaTypeKind

    /// Type of the reaction
    public var reactionType: ReactionType

    /// *Optional*. Pass *True* if the reaction area has a dark background
    public var isDark: Swift.Bool?

    /// *Optional*. Pass *True* if reaction area corner is flipped
    public var isFlipped: Swift.Bool?

    public init(
        type: StoryAreaTypeKind = .suggestedReaction,
        reactionType: ReactionType,
        isDark: Swift.Bool? = nil,
        isFlipped: Swift.Bool? = nil
    ) {
        self.type = type
        self.reactionType = reactionType
        self.isDark = isDark
        self.isFlipped = isFlipped
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case reactionType = "reaction_type"
        case isDark = "is_dark"
        case isFlipped = "is_flipped"
    }
}
