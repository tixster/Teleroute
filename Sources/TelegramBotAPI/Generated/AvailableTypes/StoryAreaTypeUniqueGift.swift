// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a story area pointing to a unique gift. Currently, a story can have at most 1
/// unique gift area.
public struct StoryAreaTypeUniqueGift: Codable, Hashable, Sendable {
    /// Type of the area, always “unique_gift”
    public var type: StoryAreaTypeKind

    /// Unique name of the gift
    public var name: Swift.String

    public init(
        type: StoryAreaTypeKind = .uniqueGift,
        name: Swift.String
    ) {
        self.type = type
        self.name = name
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case name
    }
}
