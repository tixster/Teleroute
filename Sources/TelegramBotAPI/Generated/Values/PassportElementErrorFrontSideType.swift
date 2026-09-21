// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The section of the user's Telegram Passport which has the issue, one of “passport”,
/// “driver_license”, “identity_card”, “internal_passport”
///
/// Used by PassportElementErrorFrontSide.type, PassportElementErrorSelfie.type.
public enum PassportElementErrorFrontSideType: RawRepresentable, Codable, Hashable, Sendable {
    case passport
    case driverLicense
    case identityCard
    case internalPassport
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .passport: "passport"
        case .driverLicense: "driver_license"
        case .identityCard: "identity_card"
        case .internalPassport: "internal_passport"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "passport": self = .passport
        case "driver_license": self = .driverLicense
        case "identity_card": self = .identityCard
        case "internal_passport": self = .internalPassport
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
    public static let documentedCases: [PassportElementErrorFrontSideType] = [
        .passport,
        .driverLicense,
        .identityCard,
        .internalPassport,
    ]
}
