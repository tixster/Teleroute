// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The section of the user's Telegram Passport which has the error, one of “personal_details”,
/// “passport”, “driver_license”, “identity_card”, “internal_passport”, “address”
public enum PassportElementErrorDataFieldType: RawRepresentable, Codable, Hashable, Sendable {
    case personalDetails
    case passport
    case driverLicense
    case identityCard
    case internalPassport
    case address
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .personalDetails: "personal_details"
        case .passport: "passport"
        case .driverLicense: "driver_license"
        case .identityCard: "identity_card"
        case .internalPassport: "internal_passport"
        case .address: "address"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "personal_details": self = .personalDetails
        case "passport": self = .passport
        case "driver_license": self = .driverLicense
        case "identity_card": self = .identityCard
        case "internal_passport": self = .internalPassport
        case "address": self = .address
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
    public static let documentedCases: [PassportElementErrorDataFieldType] = [
        .personalDetails,
        .passport,
        .driverLicense,
        .identityCard,
        .internalPassport,
        .address,
    ]
}
