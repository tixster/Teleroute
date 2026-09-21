// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// *Optional*. Style of the button. Must be one of “danger”, “success”, “primary”, or “link”
/// (the button is shown as a regular link without borders). Apps may use theme-specific colors
/// for the button background and text based on the style. The style “link” is allowed only for
/// callback buttons.
public enum RichMessageButtonStyle: RawRepresentable, Codable, Hashable, Sendable {
    case danger
    case success
    case primary
    case link
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .danger: "danger"
        case .success: "success"
        case .primary: "primary"
        case .link: "link"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "danger": self = .danger
        case "success": self = .success
        case "primary": self = .primary
        case "link": self = .link
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
    public static let documentedCases: [RichMessageButtonStyle] = [
        .danger,
        .success,
        .primary,
        .link,
    ]
}
