// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Type of element of the user's Telegram Passport which has the issue, one of “passport”,
/// “driver_license”, “identity_card”, “internal_passport”, “utility_bill”, “bank_statement”,
/// “rental_agreement”, “passport_registration”, “temporary_registration”
///
/// Used by PassportElementErrorTranslationFile.type, PassportElementErrorTranslationFiles.type.
public enum PassportElementErrorTranslationFileType: RawRepresentable, Codable, Hashable, Sendable {
    case passport
    case driverLicense
    case identityCard
    case internalPassport
    case utilityBill
    case bankStatement
    case rentalAgreement
    case passportRegistration
    case temporaryRegistration
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .passport: "passport"
        case .driverLicense: "driver_license"
        case .identityCard: "identity_card"
        case .internalPassport: "internal_passport"
        case .utilityBill: "utility_bill"
        case .bankStatement: "bank_statement"
        case .rentalAgreement: "rental_agreement"
        case .passportRegistration: "passport_registration"
        case .temporaryRegistration: "temporary_registration"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "passport": self = .passport
        case "driver_license": self = .driverLicense
        case "identity_card": self = .identityCard
        case "internal_passport": self = .internalPassport
        case "utility_bill": self = .utilityBill
        case "bank_statement": self = .bankStatement
        case "rental_agreement": self = .rentalAgreement
        case "passport_registration": self = .passportRegistration
        case "temporary_registration": self = .temporaryRegistration
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
    public static let documentedCases: [PassportElementErrorTranslationFileType] = [
        .passport,
        .driverLicense,
        .identityCard,
        .internalPassport,
        .utilityBill,
        .bankStatement,
        .rentalAgreement,
        .passportRegistration,
        .temporaryRegistration,
    ]
}
