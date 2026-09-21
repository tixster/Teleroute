// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes a message that can be inaccessible to the bot. It can be one of
public indirect enum MaybeInaccessibleMessage: Codable, Hashable, Sendable {
    case Message(TelegramBotAPI.Message)
    case InaccessibleMessage(TelegramBotAPI.InaccessibleMessage)

    public init(from decoder: any Decoder) throws {
        var errors: [any Error] = []
        do {
            self = .Message(try TelegramBotAPI.Message(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InaccessibleMessage(try TelegramBotAPI.InaccessibleMessage(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        throw DecodingError.typeMismatch(
            Self.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "no variant of MaybeInaccessibleMessage could decode the payload",
                underlyingError: errors.first
            )
        )
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .Message(value):
            try value.encode(to: encoder)
        case let .InaccessibleMessage(value):
            try value.encode(to: encoder)
        }
    }
}
