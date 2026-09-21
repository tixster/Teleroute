// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The section of the user's Telegram Passport which has the issue, one of “utility_bill”,
/// “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
///
/// Used by PassportElementErrorFile.type, PassportElementErrorFiles.type.
public enum PassportElementErrorFileType: RawRepresentable, Codable, Hashable, Sendable {
    case utilityBill
    case bankStatement
    case rentalAgreement
    case passportRegistration
    case temporaryRegistration
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
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
    public static let documentedCases: [PassportElementErrorFileType] = [
        .utilityBill,
        .bankStatement,
        .rentalAgreement,
        .passportRegistration,
        .temporaryRegistration,
    ]
}
