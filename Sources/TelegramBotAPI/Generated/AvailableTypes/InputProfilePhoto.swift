// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes a profile photo to set. Currently, it can be one of
public enum InputProfilePhoto: Codable, Hashable, Sendable {
    case _static(InputProfilePhotoStatic)
    case animated(InputProfilePhotoAnimated)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "static":
            self = ._static(try InputProfilePhotoStatic(from: decoder))
        case "animated":
            self = .animated(try InputProfilePhotoAnimated(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown InputProfilePhoto type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let ._static(value):
            try value.encode(to: encoder)
        case let .animated(value):
            try value.encode(to: encoder)
        }
    }
}
