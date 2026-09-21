// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The `type` a ``InputPollMedia`` variant carries.
public enum InputPollMediaKind: RawRepresentable, Codable, Hashable, Sendable {
    case animation
    case audio
    case document
    case livePhoto
    case location
    case photo
    case venue
    case video
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .animation: "animation"
        case .audio: "audio"
        case .document: "document"
        case .livePhoto: "live_photo"
        case .location: "location"
        case .photo: "photo"
        case .venue: "venue"
        case .video: "video"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "animation": self = .animation
        case "audio": self = .audio
        case "document": self = .document
        case "live_photo": self = .livePhoto
        case "location": self = .location
        case "photo": self = .photo
        case "venue": self = .venue
        case "video": self = .video
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
    public static let documentedCases: [InputPollMediaKind] = [
        .animation,
        .audio,
        .document,
        .livePhoto,
        .location,
        .photo,
        .venue,
        .video,
    ]
}
