// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the theme of the screen for sharing a link to a user or a chat.
/// Currently, it can be one of
public enum ChatShareTheme: Codable, Hashable, Sendable {
    case emoji(ChatShareThemeEmoji)
    case uniqueGift(ChatShareThemeUniqueGift)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "emoji":
            self = .emoji(try ChatShareThemeEmoji(from: decoder))
        case "unique_gift":
            self = .uniqueGift(try ChatShareThemeUniqueGift(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown ChatShareTheme type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .emoji(value):
            try value.encode(to: encoder)
        case let .uniqueGift(value):
            try value.encode(to: encoder)
        }
    }
}
