// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Type of the chat, can be either “private”, “group”, “supergroup” or “channel”
///
/// Used by Chat.type, ChatFullInfo.type.
public enum ChatType: RawRepresentable, Codable, Hashable, Sendable {
    case `private`
    case group
    case supergroup
    case channel
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .private: "private"
        case .group: "group"
        case .supergroup: "supergroup"
        case .channel: "channel"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
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
    public static let documentedCases: [ChatType] = [
        .private,
        .group,
        .supergroup,
        .channel,
    ]
}
