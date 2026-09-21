// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The `type` a ``InputPaidMedia`` variant carries.
public enum InputPaidMediaKind: RawRepresentable, Codable, Hashable, Sendable {
    case livePhoto
    case photo
    case video
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .livePhoto: "live_photo"
        case .photo: "photo"
        case .video: "video"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "live_photo": self = .livePhoto
        case "photo": self = .photo
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
    public static let documentedCases: [InputPaidMediaKind] = [
        .livePhoto,
        .photo,
        .video,
    ]
}
