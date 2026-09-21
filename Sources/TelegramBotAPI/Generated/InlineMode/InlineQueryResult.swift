// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents one result of an inline query. Telegram clients currently support
/// results of the following 20 types: **Note:** All URLs passed in inline query results will be
/// available to end users and therefore must be assumed to be **public**.
public enum InlineQueryResult: Codable, Hashable, Sendable {
    case InlineQueryResultCachedAudio(TelegramBotAPI.InlineQueryResultCachedAudio)
    case InlineQueryResultCachedDocument(TelegramBotAPI.InlineQueryResultCachedDocument)
    case InlineQueryResultCachedGif(TelegramBotAPI.InlineQueryResultCachedGif)
    case InlineQueryResultCachedMpeg4Gif(TelegramBotAPI.InlineQueryResultCachedMpeg4Gif)
    case InlineQueryResultCachedPhoto(TelegramBotAPI.InlineQueryResultCachedPhoto)
    case InlineQueryResultCachedSticker(TelegramBotAPI.InlineQueryResultCachedSticker)
    case InlineQueryResultCachedVideo(TelegramBotAPI.InlineQueryResultCachedVideo)
    case InlineQueryResultCachedVoice(TelegramBotAPI.InlineQueryResultCachedVoice)
    case InlineQueryResultArticle(TelegramBotAPI.InlineQueryResultArticle)
    case InlineQueryResultAudio(TelegramBotAPI.InlineQueryResultAudio)
    case InlineQueryResultContact(TelegramBotAPI.InlineQueryResultContact)
    case InlineQueryResultGame(TelegramBotAPI.InlineQueryResultGame)
    case InlineQueryResultDocument(TelegramBotAPI.InlineQueryResultDocument)
    case InlineQueryResultGif(TelegramBotAPI.InlineQueryResultGif)
    case InlineQueryResultLocation(TelegramBotAPI.InlineQueryResultLocation)
    case InlineQueryResultMpeg4Gif(TelegramBotAPI.InlineQueryResultMpeg4Gif)
    case InlineQueryResultPhoto(TelegramBotAPI.InlineQueryResultPhoto)
    case InlineQueryResultVenue(TelegramBotAPI.InlineQueryResultVenue)
    case InlineQueryResultVideo(TelegramBotAPI.InlineQueryResultVideo)
    case InlineQueryResultVoice(TelegramBotAPI.InlineQueryResultVoice)

    public init(from decoder: any Decoder) throws {
        var errors: [any Error] = []
        do {
            self = .InlineQueryResultCachedAudio(try TelegramBotAPI.InlineQueryResultCachedAudio(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultCachedDocument(try TelegramBotAPI.InlineQueryResultCachedDocument(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultCachedGif(try TelegramBotAPI.InlineQueryResultCachedGif(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultCachedMpeg4Gif(try TelegramBotAPI.InlineQueryResultCachedMpeg4Gif(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultCachedPhoto(try TelegramBotAPI.InlineQueryResultCachedPhoto(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultCachedSticker(try TelegramBotAPI.InlineQueryResultCachedSticker(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultCachedVideo(try TelegramBotAPI.InlineQueryResultCachedVideo(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultCachedVoice(try TelegramBotAPI.InlineQueryResultCachedVoice(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultArticle(try TelegramBotAPI.InlineQueryResultArticle(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultAudio(try TelegramBotAPI.InlineQueryResultAudio(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultContact(try TelegramBotAPI.InlineQueryResultContact(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultGame(try TelegramBotAPI.InlineQueryResultGame(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultDocument(try TelegramBotAPI.InlineQueryResultDocument(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultGif(try TelegramBotAPI.InlineQueryResultGif(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultLocation(try TelegramBotAPI.InlineQueryResultLocation(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultMpeg4Gif(try TelegramBotAPI.InlineQueryResultMpeg4Gif(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultPhoto(try TelegramBotAPI.InlineQueryResultPhoto(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultVenue(try TelegramBotAPI.InlineQueryResultVenue(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultVideo(try TelegramBotAPI.InlineQueryResultVideo(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        do {
            self = .InlineQueryResultVoice(try TelegramBotAPI.InlineQueryResultVoice(from: decoder))
            return
        } catch {
            errors.append(error)
        }
        throw DecodingError.typeMismatch(
            Self.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "no variant of InlineQueryResult could decode the payload",
                underlyingError: errors.first
            )
        )
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .InlineQueryResultCachedAudio(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultCachedDocument(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultCachedGif(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultCachedMpeg4Gif(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultCachedPhoto(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultCachedSticker(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultCachedVideo(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultCachedVoice(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultArticle(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultAudio(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultContact(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultGame(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultDocument(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultGif(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultLocation(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultMpeg4Gif(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultPhoto(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultVenue(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultVideo(value):
            try value.encode(to: encoder)
        case let .InlineQueryResultVoice(value):
            try value.encode(to: encoder)
        }
    }
}
