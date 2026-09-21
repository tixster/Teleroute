// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A chat identifier: either a numeric id or an `@username`.
public enum ChatId: Codable, Hashable, Sendable {
    case case1(Swift.Int64)
    case case2(Swift.String)

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let id = try? container.decode(Swift.Int64.self) {
            self = .case1(id)
            return
        }
        self = .case2(try container.decode(Swift.String.self))
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .case1(id): try container.encode(id)
        case let .case2(username): try container.encode(username)
        }
    }
}
