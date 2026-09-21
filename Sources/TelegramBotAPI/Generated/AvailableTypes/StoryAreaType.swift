// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes the type of a clickable area on a story. Currently, it can be one of
public enum StoryAreaType: Codable, Hashable, Sendable {
    case location(StoryAreaTypeLocation)
    case suggestedReaction(StoryAreaTypeSuggestedReaction)
    case link(StoryAreaTypeLink)
    case weather(StoryAreaTypeWeather)
    case uniqueGift(StoryAreaTypeUniqueGift)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "location":
            self = .location(try StoryAreaTypeLocation(from: decoder))
        case "suggested_reaction":
            self = .suggestedReaction(try StoryAreaTypeSuggestedReaction(from: decoder))
        case "link":
            self = .link(try StoryAreaTypeLink(from: decoder))
        case "weather":
            self = .weather(try StoryAreaTypeWeather(from: decoder))
        case "unique_gift":
            self = .uniqueGift(try StoryAreaTypeUniqueGift(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown StoryAreaType type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .location(value):
            try value.encode(to: encoder)
        case let .suggestedReaction(value):
            try value.encode(to: encoder)
        case let .link(value):
            try value.encode(to: encoder)
        case let .weather(value):
            try value.encode(to: encoder)
        case let .uniqueGift(value):
            try value.encode(to: encoder)
        }
    }
}
