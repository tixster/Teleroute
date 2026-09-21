// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The `type` a ``RichMessageInputMedia`` variant carries.
public enum RichMessageInputMediaKind: RawRepresentable, Codable, Hashable, Sendable {
    case animation
    case audio
    case document
    case photo
    case video
    case voiceNote
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .animation: "animation"
        case .audio: "audio"
        case .document: "document"
        case .photo: "photo"
        case .video: "video"
        case .voiceNote: "voice_note"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "animation": self = .animation
        case "audio": self = .audio
        case "document": self = .document
        case "photo": self = .photo
        case "video": self = .video
        case "voice_note": self = .voiceNote
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
    public static let documentedCases: [RichMessageInputMediaKind] = [
        .animation,
        .audio,
        .document,
        .photo,
        .video,
        .voiceNote,
    ]
}
