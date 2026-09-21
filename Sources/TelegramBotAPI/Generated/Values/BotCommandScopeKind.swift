// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The `type` a ``BotCommandScope`` variant carries.
public enum BotCommandScopeKind: RawRepresentable, Codable, Hashable, Sendable {
    case `default`
    case allPrivateChats
    case allGroupChats
    case allChatAdministrators
    case chat
    case chatAdministrators
    case chatMember
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .default: "default"
        case .allPrivateChats: "all_private_chats"
        case .allGroupChats: "all_group_chats"
        case .allChatAdministrators: "all_chat_administrators"
        case .chat: "chat"
        case .chatAdministrators: "chat_administrators"
        case .chatMember: "chat_member"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "default": self = .default
        case "all_private_chats": self = .allPrivateChats
        case "all_group_chats": self = .allGroupChats
        case "all_chat_administrators": self = .allChatAdministrators
        case "chat": self = .chat
        case "chat_administrators": self = .chatAdministrators
        case "chat_member": self = .chatMember
        default: self = .unknown(rawValue)
        }
    }

    public init(from decoder: any Decoder) throws {
        self.init(rawValue: try decoder.singleValueContainer().decode(Swift.String.self))
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }

    /// Every value documented at the time these sources were generated.
    public static let documentedCases: [BotCommandScopeKind] = [
        .default,
        .allPrivateChats,
        .allGroupChats,
        .allChatAdministrators,
        .chat,
        .chatAdministrators,
        .chatMember,
    ]
}
