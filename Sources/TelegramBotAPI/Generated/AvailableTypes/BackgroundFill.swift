// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the way a background is filled based on the selected colors.
/// Currently, it can be one of
public enum BackgroundFill: Codable, Hashable, Sendable {
    case solid(BackgroundFillSolid)
    case gradient(BackgroundFillGradient)
    case freeformGradient(BackgroundFillFreeformGradient)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "solid":
            self = .solid(try BackgroundFillSolid(from: decoder))
        case "gradient":
            self = .gradient(try BackgroundFillGradient(from: decoder))
        case "freeform_gradient":
            self = .freeformGradient(try BackgroundFillFreeformGradient(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown BackgroundFill type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .solid(value):
            try value.encode(to: encoder)
        case let .gradient(value):
            try value.encode(to: encoder)
        case let .freeformGradient(value):
            try value.encode(to: encoder)
        }
    }
}
