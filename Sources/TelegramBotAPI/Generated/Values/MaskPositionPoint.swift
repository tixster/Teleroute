// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The part of the face relative to which the mask should be placed. One of “forehead”, “eyes”,
/// “mouth”, or “chin”.
public enum MaskPositionPoint: RawRepresentable, Codable, Hashable, Sendable {
    case forehead
    case eyes
    case mouth
    case chin
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .forehead: "forehead"
        case .eyes: "eyes"
        case .mouth: "mouth"
        case .chin: "chin"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "forehead": self = .forehead
        case "eyes": self = .eyes
        case "mouth": self = .mouth
        case "chin": self = .chin
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
    public static let documentedCases: [MaskPositionPoint] = [
        .forehead,
        .eyes,
        .mouth,
        .chin,
    ]
}
