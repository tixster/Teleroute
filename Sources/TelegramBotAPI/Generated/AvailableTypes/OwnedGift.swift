// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes a gift received and owned by a user or a chat. Currently, it can be
/// one of
public enum OwnedGift: Codable, Hashable, Sendable {
    case regular(OwnedGiftRegular)
    case unique(OwnedGiftUnique)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "regular":
            self = .regular(try OwnedGiftRegular(from: decoder))
        case "unique":
            self = .unique(try OwnedGiftUnique(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown OwnedGift type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .regular(value):
            try value.encode(to: encoder)
        case let .unique(value):
            try value.encode(to: encoder)
        }
    }
}
