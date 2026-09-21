// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the content of a story to post. Currently, it can be one of
public enum InputStoryContent: Codable, Hashable, Sendable {
    case photo(InputStoryContentPhoto)
    case video(InputStoryContentVideo)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "photo":
            self = .photo(try InputStoryContentPhoto(from: decoder))
        case "video":
            self = .video(try InputStoryContentVideo(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown InputStoryContent type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .photo(value):
            try value.encode(to: encoder)
        case let .video(value):
            try value.encode(to: encoder)
        }
    }
}
