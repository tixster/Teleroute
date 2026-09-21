// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents the content of a message to be sent as a result of an inline query.
/// Telegram clients currently support the following types:
public enum InputMessageContent: Codable, Hashable, Sendable {
    case InputTextMessageContent(TelegramBotAPI.InputTextMessageContent)
    case InputRichMessageContent(TelegramBotAPI.InputRichMessageContent)
    case InputLocationMessageContent(TelegramBotAPI.InputLocationMessageContent)
    case InputVenueMessageContent(TelegramBotAPI.InputVenueMessageContent)
    case InputContactMessageContent(TelegramBotAPI.InputContactMessageContent)
    case InputInvoiceMessageContent(TelegramBotAPI.InputInvoiceMessageContent)

    public init(from decoder: any Decoder) throws {
        var errors: [any Error] = []
        do {
            self = .InputTextMessageContent(try TelegramBotAPI.InputTextMessageContent(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InputRichMessageContent(try TelegramBotAPI.InputRichMessageContent(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InputLocationMessageContent(try TelegramBotAPI.InputLocationMessageContent(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InputVenueMessageContent(try TelegramBotAPI.InputVenueMessageContent(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InputContactMessageContent(try TelegramBotAPI.InputContactMessageContent(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InputInvoiceMessageContent(try TelegramBotAPI.InputInvoiceMessageContent(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        throw DecodingError.typeMismatch(
            Self.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "no variant of InputMessageContent could decode the payload",
                underlyingError: errors.first
            )
        )
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .InputTextMessageContent(value):
            try value.encode(to: encoder)
        case let .InputRichMessageContent(value):
            try value.encode(to: encoder)
        case let .InputLocationMessageContent(value):
            try value.encode(to: encoder)
        case let .InputVenueMessageContent(value):
            try value.encode(to: encoder)
        case let .InputContactMessageContent(value):
            try value.encode(to: encoder)
        case let .InputInvoiceMessageContent(value):
            try value.encode(to: encoder)
        }
    }
}
