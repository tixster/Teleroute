// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Vertical cell content alignment. Currently, must be one of “top”, “middle”, or “bottom”.
public enum RichBlockTableCellValign: RawRepresentable, Codable, Hashable, Sendable {
    case top
    case middle
    case bottom
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .top: "top"
        case .middle: "middle"
        case .bottom: "bottom"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "top": self = .top
        case "middle": self = .middle
        case "bottom": self = .bottom
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
    public static let documentedCases: [RichBlockTableCellValign] = [
        .top,
        .middle,
        .bottom,
    ]
}
