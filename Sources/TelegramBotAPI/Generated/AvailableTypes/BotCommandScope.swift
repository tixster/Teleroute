// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents the scope to which bot commands are applied. Currently, the following
/// 7 scopes are supported:
public enum BotCommandScope: Codable, Hashable, Sendable {
    case _default(BotCommandScopeDefault)
    case allPrivateChats(BotCommandScopeAllPrivateChats)
    case allGroupChats(BotCommandScopeAllGroupChats)
    case allChatAdministrators(BotCommandScopeAllChatAdministrators)
    case chat(BotCommandScopeChat)
    case chatAdministrators(BotCommandScopeChatAdministrators)
    case chatMember(BotCommandScopeChatMember)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "default":
            self = ._default(try BotCommandScopeDefault(from: decoder))
        case "all_private_chats":
            self = .allPrivateChats(try BotCommandScopeAllPrivateChats(from: decoder))
        case "all_group_chats":
            self = .allGroupChats(try BotCommandScopeAllGroupChats(from: decoder))
        case "all_chat_administrators":
            self = .allChatAdministrators(try BotCommandScopeAllChatAdministrators(from: decoder))
        case "chat":
            self = .chat(try BotCommandScopeChat(from: decoder))
        case "chat_administrators":
            self = .chatAdministrators(try BotCommandScopeChatAdministrators(from: decoder))
        case "chat_member":
            self = .chatMember(try BotCommandScopeChatMember(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown BotCommandScope type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let ._default(value):
            try value.encode(to: encoder)
        case let .allPrivateChats(value):
            try value.encode(to: encoder)
        case let .allGroupChats(value):
            try value.encode(to: encoder)
        case let .allChatAdministrators(value):
            try value.encode(to: encoder)
        case let .chat(value):
            try value.encode(to: encoder)
        case let .chatAdministrators(value):
            try value.encode(to: encoder)
        case let .chatMember(value):
            try value.encode(to: encoder)
        }
    }
}
