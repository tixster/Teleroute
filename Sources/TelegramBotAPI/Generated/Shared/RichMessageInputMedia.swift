// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The media carried by an ``InputRichMessageMedia`` block.
public enum RichMessageInputMedia: Codable, Hashable, Sendable {
    case animation(InputMediaAnimation)
    case audio(InputMediaAudio)
    case document(InputMediaDocument)
    case photo(InputMediaPhoto)
    case video(InputMediaVideo)
    case voiceNote(InputMediaVoiceNote)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "animation":
            self = .animation(try InputMediaAnimation(from: decoder))
        case "audio":
            self = .audio(try InputMediaAudio(from: decoder))
        case "document":
            self = .document(try InputMediaDocument(from: decoder))
        case "photo":
            self = .photo(try InputMediaPhoto(from: decoder))
        case "video":
            self = .video(try InputMediaVideo(from: decoder))
        case "voice_note":
            self = .voiceNote(try InputMediaVoiceNote(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown RichMessageInputMedia type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .animation(value):
            try value.encode(to: encoder)
        case let .audio(value):
            try value.encode(to: encoder)
        case let .document(value):
            try value.encode(to: encoder)
        case let .photo(value):
            try value.encode(to: encoder)
        case let .video(value):
            try value.encode(to: encoder)
        case let .voiceNote(value):
            try value.encode(to: encoder)
        }
    }
}
