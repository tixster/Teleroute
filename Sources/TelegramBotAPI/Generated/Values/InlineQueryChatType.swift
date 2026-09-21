// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// *Optional*. Type of the chat from which the inline query was sent. Can be either “sender”
/// for a private chat with the inline query sender, “private”, “group”, “supergroup”, or
/// “channel”. The chat type should be always known for requests sent from official clients and
/// most third-party clients, unless the request was sent from a secret chat.
public enum InlineQueryChatType: RawRepresentable, Codable, Hashable, Sendable {
    case sender
    case `private`
    case group
    case supergroup
    case channel
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .sender: "sender"
        case .private: "private"
        case .group: "group"
        case .supergroup: "supergroup"
        case .channel: "channel"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "sender": self = .sender
        case "private": self = .private
        case "group": self = .group
        case "supergroup": self = .supergroup
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
    public static let documentedCases: [InlineQueryChatType] = [
        .sender,
        .private,
        .group,
        .supergroup,
        .channel,
    ]
}
