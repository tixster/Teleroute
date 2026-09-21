// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The `source` a ``PassportElementError`` variant carries.
public enum PassportElementErrorKind: RawRepresentable, Codable, Hashable, Sendable {
    case data
    case frontSide
    case reverseSide
    case selfie
    case file
    case files
    case translationFile
    case translationFiles
    case unspecified
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .data: "data"
        case .frontSide: "front_side"
        case .reverseSide: "reverse_side"
        case .selfie: "selfie"
        case .file: "file"
        case .files: "files"
        case .translationFile: "translation_file"
        case .translationFiles: "translation_files"
        case .unspecified: "unspecified"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "data": self = .data
        case "front_side": self = .frontSide
        case "reverse_side": self = .reverseSide
        case "selfie": self = .selfie
        case "file": self = .file
        case "files": self = .files
        case "translation_file": self = .translationFile
        case "translation_files": self = .translationFiles
        case "unspecified": self = .unspecified
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
    public static let documentedCases: [PassportElementErrorKind] = [
        .data,
        .frontSide,
        .reverseSide,
        .selfie,
        .file,
        .files,
        .translationFile,
        .translationFiles,
        .unspecified,
    ]
}
