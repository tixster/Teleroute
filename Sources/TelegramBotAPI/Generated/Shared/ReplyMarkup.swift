// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Additional interface options for a message: an inline keyboard, a custom reply keyboard,
/// instructions to remove a reply keyboard, or to force a reply from the user.
public enum ReplyMarkup: Codable, Hashable, Sendable {
    case InlineKeyboardMarkup(TelegramBotAPI.InlineKeyboardMarkup)
    case ReplyKeyboardMarkup(TelegramBotAPI.ReplyKeyboardMarkup)
    case ReplyKeyboardRemove(TelegramBotAPI.ReplyKeyboardRemove)
    case ForceReply(TelegramBotAPI.ForceReply)

    public init(from decoder: any Decoder) throws {
        var errors: [any Error] = []
        do {
            self = .InlineKeyboardMarkup(try TelegramBotAPI.InlineKeyboardMarkup(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .ReplyKeyboardMarkup(try TelegramBotAPI.ReplyKeyboardMarkup(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .ReplyKeyboardRemove(try TelegramBotAPI.ReplyKeyboardRemove(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .ForceReply(try TelegramBotAPI.ForceReply(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        throw DecodingError.typeMismatch(
            Self.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "no variant of ReplyMarkup could decode the payload",
                underlyingError: errors.first
            )
        )
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .InlineKeyboardMarkup(value):
            try value.encode(to: encoder)
        case let .ReplyKeyboardMarkup(value):
            try value.encode(to: encoder)
        case let .ReplyKeyboardRemove(value):
            try value.encode(to: encoder)
        case let .ForceReply(value):
            try value.encode(to: encoder)
        }
    }
}
