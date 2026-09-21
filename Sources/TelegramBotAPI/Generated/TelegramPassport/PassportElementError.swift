// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents an error in the Telegram Passport element which was submitted that
/// should be resolved by the user. It should be one of:
public enum PassportElementError: Codable, Hashable, Sendable {
    case data(PassportElementErrorDataField)
    case frontSide(PassportElementErrorFrontSide)
    case reverseSide(PassportElementErrorReverseSide)
    case selfie(PassportElementErrorSelfie)
    case file(PassportElementErrorFile)
    case files(PassportElementErrorFiles)
    case translationFile(PassportElementErrorTranslationFile)
    case translationFiles(PassportElementErrorTranslationFiles)
    case unspecified(PassportElementErrorUnspecified)

    public enum CodingKeys: String, CodingKey {
        case source
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .source) {
        case "data":
            self = .data(try PassportElementErrorDataField(from: decoder))
        case "front_side":
            self = .frontSide(try PassportElementErrorFrontSide(from: decoder))
        case "reverse_side":
            self = .reverseSide(try PassportElementErrorReverseSide(from: decoder))
        case "selfie":
            self = .selfie(try PassportElementErrorSelfie(from: decoder))
        case "file":
            self = .file(try PassportElementErrorFile(from: decoder))
        case "files":
            self = .files(try PassportElementErrorFiles(from: decoder))
        case "translation_file":
            self = .translationFile(try PassportElementErrorTranslationFile(from: decoder))
        case "translation_files":
            self = .translationFiles(try PassportElementErrorTranslationFiles(from: decoder))
        case "unspecified":
            self = .unspecified(try PassportElementErrorUnspecified(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .source, in: container,
                debugDescription: "unknown PassportElementError source '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .data(value):
            try value.encode(to: encoder)
        case let .frontSide(value):
            try value.encode(to: encoder)
        case let .reverseSide(value):
            try value.encode(to: encoder)
        case let .selfie(value):
            try value.encode(to: encoder)
        case let .file(value):
            try value.encode(to: encoder)
        case let .files(value):
            try value.encode(to: encoder)
        case let .translationFile(value):
            try value.encode(to: encoder)
        case let .translationFiles(value):
            try value.encode(to: encoder)
        case let .unspecified(value):
            try value.encode(to: encoder)
        }
    }
}
