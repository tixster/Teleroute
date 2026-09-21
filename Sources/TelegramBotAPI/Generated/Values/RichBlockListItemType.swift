// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// *Optional*. For ordered lists, the type of the item label; must be one of “a” for lowercase
/// letters, “A” for uppercase letters, “i” for lowercase Roman numerals, “I” for uppercase
/// Roman numerals, or “1” for decimal numbers
///
/// Used by RichBlockListItem.type, InputRichBlockListItem.type.
public enum RichBlockListItemType: RawRepresentable, Codable, Hashable, Sendable {
    case a
    case A
    case i
    case I
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .a: "a"
        case .A: "A"
        case .i: "i"
        case .I: "I"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "a": self = .a
        case "A": self = .A
        case "i": self = .i
        case "I": self = .I
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
    public static let documentedCases: [RichBlockListItemType] = [
        .a,
        .A,
        .i,
        .I,
    ]
}
