// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes an emoji. Currently, it can be one of
public enum EmojiType: Codable, Hashable, Sendable {
    case emoji(EmojiTypeEmoji)
    case customEmoji(EmojiTypeCustomEmoji)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "emoji":
            self = .emoji(try EmojiTypeEmoji(from: decoder))
        case "custom_emoji":
            self = .customEmoji(try EmojiTypeCustomEmoji(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown EmojiType type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .emoji(value):
            try value.encode(to: encoder)
        case let .customEmoji(value):
            try value.encode(to: encoder)
        }
    }
}
