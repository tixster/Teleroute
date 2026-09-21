// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains information about one member of a chat. Currently, the following 6
/// types of chat members are supported:
public enum ChatMember: Codable, Hashable, Sendable {
    case creator(ChatMemberOwner)
    case administrator(ChatMemberAdministrator)
    case member(ChatMemberMember)
    case restricted(ChatMemberRestricted)
    case left(ChatMemberLeft)
    case kicked(ChatMemberBanned)

    public enum CodingKeys: String, CodingKey {
        case status
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .status) {
        case "creator":
            self = .creator(try ChatMemberOwner(from: decoder))
        case "administrator":
            self = .administrator(try ChatMemberAdministrator(from: decoder))
        case "member":
            self = .member(try ChatMemberMember(from: decoder))
        case "restricted":
            self = .restricted(try ChatMemberRestricted(from: decoder))
        case "left":
            self = .left(try ChatMemberLeft(from: decoder))
        case "kicked":
            self = .kicked(try ChatMemberBanned(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .status, in: container,
                debugDescription: "unknown ChatMember status '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .creator(value):
            try value.encode(to: encoder)
        case let .administrator(value):
            try value.encode(to: encoder)
        case let .member(value):
            try value.encode(to: encoder)
        case let .restricted(value):
            try value.encode(to: encoder)
        case let .left(value):
            try value.encode(to: encoder)
        case let .kicked(value):
            try value.encode(to: encoder)
        }
    }
}
