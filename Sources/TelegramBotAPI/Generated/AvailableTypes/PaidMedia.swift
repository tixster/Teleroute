// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes paid media. Currently, it can be one of
public enum PaidMedia: Codable, Hashable, Sendable {
    case livePhoto(PaidMediaLivePhoto)
    case photo(PaidMediaPhoto)
    case preview(PaidMediaPreview)
    case video(PaidMediaVideo)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "live_photo":
            self = .livePhoto(try PaidMediaLivePhoto(from: decoder))
        case "photo":
            self = .photo(try PaidMediaPhoto(from: decoder))
        case "preview":
            self = .preview(try PaidMediaPreview(from: decoder))
        case "video":
            self = .video(try PaidMediaVideo(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown PaidMedia type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .livePhoto(value):
            try value.encode(to: encoder)
        case let .photo(value):
            try value.encode(to: encoder)
        case let .preview(value):
            try value.encode(to: encoder)
        case let .video(value):
            try value.encode(to: encoder)
        }
    }
}
