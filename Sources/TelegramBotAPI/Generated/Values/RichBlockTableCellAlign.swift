// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Horizontal cell content alignment. Currently, must be one of “left”, “center”, or “right”.
///
/// Used by RichBlockTableCell.align, RichBlockButtons.align, InputRichBlockButtons.align.
public enum RichBlockTableCellAlign: RawRepresentable, Codable, Hashable, Sendable {
    case left
    case center
    case right
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .left: "left"
        case .center: "center"
        case .right: "right"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "left": self = .left
        case "center": self = .center
        case "right": self = .right
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
    public static let documentedCases: [RichBlockTableCellAlign] = [
        .left,
        .center,
        .right,
    ]
}
