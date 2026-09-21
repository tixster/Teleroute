// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Format of the added sticker, must be one of “static” for a **.WEBP** or **.PNG** image,
/// “animated” for a **.TGS** animation, “video” for a **.WEBM** video
///
/// Used by InputSticker.format, uploadStickerFile.sticker_format,
/// setStickerSetThumbnail.format.
public enum InputStickerFormat: RawRepresentable, Codable, Hashable, Sendable {
    case `static`
    case animated
    case video
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .static: "static"
        case .animated: "animated"
        case .video: "video"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "static": self = .static
        case "animated": self = .animated
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
    public static let documentedCases: [InputStickerFormat] = [
        .static,
        .animated,
        .video,
    ]
}
