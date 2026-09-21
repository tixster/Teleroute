// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The `type` a ``MessageOrigin`` variant carries.
public enum MessageOriginKind: RawRepresentable, Codable, Hashable, Sendable {
    case user
    case hiddenUser
    case chat
    case channel
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .user: "user"
        case .hiddenUser: "hidden_user"
        case .chat: "chat"
        case .channel: "channel"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "user": self = .user
        case "hidden_user": self = .hiddenUser
        case "chat": self = .chat
        case "channel": self = .channel
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
    public static let documentedCases: [MessageOriginKind] = [
        .user,
        .hiddenUser,
        .chat,
        .channel,
    ]
}
