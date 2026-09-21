// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The `status` a ``ChatMember`` variant carries.
public enum ChatMemberKind: RawRepresentable, Codable, Hashable, Sendable {
    case creator
    case administrator
    case member
    case restricted
    case left
    case kicked
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .creator: "creator"
        case .administrator: "administrator"
        case .member: "member"
        case .restricted: "restricted"
        case .left: "left"
        case .kicked: "kicked"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "creator": self = .creator
        case "administrator": self = .administrator
        case "member": self = .member
        case "restricted": self = .restricted
        case "left": self = .left
        case "kicked": self = .kicked
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
    public static let documentedCases: [ChatMemberKind] = [
        .creator,
        .administrator,
        .member,
        .restricted,
        .left,
        .kicked,
    ]
}
