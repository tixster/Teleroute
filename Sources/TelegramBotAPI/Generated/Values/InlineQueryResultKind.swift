// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The `type` a ``InlineQueryResult`` variant carries.
public enum InlineQueryResultKind: RawRepresentable, Codable, Hashable, Sendable {
    case audio
    case document
    case gif
    case mpeg4Gif
    case photo
    case sticker
    case video
    case voice
    case article
    case contact
    case game
    case location
    case venue
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .audio: "audio"
        case .document: "document"
        case .gif: "gif"
        case .mpeg4Gif: "mpeg4_gif"
        case .photo: "photo"
        case .sticker: "sticker"
        case .video: "video"
        case .voice: "voice"
        case .article: "article"
        case .contact: "contact"
        case .game: "game"
        case .location: "location"
        case .venue: "venue"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "audio": self = .audio
        case "document": self = .document
        case "gif": self = .gif
        case "mpeg4_gif": self = .mpeg4Gif
        case "photo": self = .photo
        case "sticker": self = .sticker
        case "video": self = .video
        case "voice": self = .voice
        case "article": self = .article
        case "contact": self = .contact
        case "game": self = .game
        case "location": self = .location
        case "venue": self = .venue
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
    public static let documentedCases: [InlineQueryResultKind] = [
        .audio,
        .document,
        .gif,
        .mpeg4Gif,
        .photo,
        .sticker,
        .video,
        .voice,
        .article,
        .contact,
        .game,
        .location,
        .venue,
    ]
}
