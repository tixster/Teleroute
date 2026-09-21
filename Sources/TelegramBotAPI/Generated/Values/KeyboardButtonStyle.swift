// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// *Optional*. Style of the button. Must be one of “danger” (red), “success” (green) or
/// “primary” (blue). If omitted, then an app-specific style is used.
///
/// Used by KeyboardButton.style, InlineKeyboardButton.style.
public enum KeyboardButtonStyle: RawRepresentable, Codable, Hashable, Sendable {
    case danger
    case success
    case primary
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .danger: "danger"
        case .success: "success"
        case .primary: "primary"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "danger": self = .danger
        case "success": self = .success
        case "primary": self = .primary
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
    public static let documentedCases: [KeyboardButtonStyle] = [
        .danger,
        .success,
        .primary,
    ]
}
