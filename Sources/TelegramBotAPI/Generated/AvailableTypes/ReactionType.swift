// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the type of a reaction. Currently, it can be one of
public enum ReactionType: Codable, Hashable, Sendable {
    case emoji(ReactionTypeEmoji)
    case customEmoji(ReactionTypeCustomEmoji)
    case paid(ReactionTypePaid)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "emoji":
            self = .emoji(try ReactionTypeEmoji(from: decoder))
        case "custom_emoji":
            self = .customEmoji(try ReactionTypeCustomEmoji(from: decoder))
        case "paid":
            self = .paid(try ReactionTypePaid(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown ReactionType type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .emoji(value):
            try value.encode(to: encoder)
        case let .customEmoji(value):
            try value.encode(to: encoder)
        case let .paid(value):
            try value.encode(to: encoder)
        }
    }
}
