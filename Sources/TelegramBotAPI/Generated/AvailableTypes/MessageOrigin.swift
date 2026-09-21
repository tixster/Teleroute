// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the origin of a message. It can be one of
public enum MessageOrigin: Codable, Hashable, Sendable {
    case user(MessageOriginUser)
    case hiddenUser(MessageOriginHiddenUser)
    case chat(MessageOriginChat)
    case channel(MessageOriginChannel)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "user":
            self = .user(try MessageOriginUser(from: decoder))
        case "hidden_user":
            self = .hiddenUser(try MessageOriginHiddenUser(from: decoder))
        case "chat":
            self = .chat(try MessageOriginChat(from: decoder))
        case "channel":
            self = .channel(try MessageOriginChannel(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown MessageOrigin type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .user(value):
            try value.encode(to: encoder)
        case let .hiddenUser(value):
            try value.encode(to: encoder)
        case let .chat(value):
            try value.encode(to: encoder)
        case let .channel(value):
            try value.encode(to: encoder)
        }
    }
}
