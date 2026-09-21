// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Type of the sticker, currently one of “regular”, “mask”, “custom_emoji”. The type of the
/// sticker is independent from its format, which is determined by the fields *is_animated* and
/// *is_video*.
///
/// Used by Sticker.type, StickerSet.sticker_type.
public enum StickerType: RawRepresentable, Codable, Hashable, Sendable {
    case regular
    case mask
    case customEmoji
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .regular: "regular"
        case .mask: "mask"
        case .customEmoji: "custom_emoji"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "regular": self = .regular
        case "mask": self = .mask
        case "custom_emoji": self = .customEmoji
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
    public static let documentedCases: [StickerType] = [
        .regular,
        .mask,
        .customEmoji,
    ]
}
