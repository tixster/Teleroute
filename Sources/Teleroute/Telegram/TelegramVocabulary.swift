import Foundation
import TelegramBotAPI

// MARK: - Public vocabulary

/// Telegram Bot API model types re-published under stable, prefix-free names.
///
/// The underlying types are generated from the OpenAPI specification into the
/// `TelegramBotAPI` module; import that module directly to reach the full
/// `Components`/`Operations` surface.
public typealias Update = Components.Schemas.Update
public typealias Message = Components.Schemas.Message
public typealias User = Components.Schemas.User
public typealias Chat = Components.Schemas.Chat
public typealias CallbackQuery = Components.Schemas.CallbackQuery
public typealias MaybeInaccessibleMessage = Components.Schemas.MaybeInaccessibleMessage
public typealias MessageEntity = Components.Schemas.MessageEntity
public typealias BotCommand = Components.Schemas.BotCommand
public typealias BotCommandScope = Components.Schemas.BotCommandScope
public typealias ChatMember = Components.Schemas.ChatMember
public typealias ChatId = Components.Schemas.ChatId
public typealias ReplyMarkup = Components.Schemas.ReplyMarkup
public typealias InlineKeyboardMarkup = Components.Schemas.InlineKeyboardMarkup
public typealias InlineKeyboardButton = Components.Schemas.InlineKeyboardButton
public typealias ReplyKeyboardMarkup = Components.Schemas.ReplyKeyboardMarkup
public typealias ReplyKeyboardRemove = Components.Schemas.ReplyKeyboardRemove
public typealias ForceReply = Components.Schemas.ForceReply
public typealias InputMedia = Components.Schemas.InputMedia

// MARK: - Teleroute-owned enums for spec-untyped strings

/// Mode for parsing entities in message text.
public enum ParseMode: String, Sendable, Hashable {
    case markdownV2 = "MarkdownV2"
    case html = "HTML"
    case markdown = "Markdown"
}

/// Telegram chat type. The specification models `Chat.type` as a plain string;
/// this enum provides the documented values.
public enum ChatType: String, Sendable, Hashable {
    case `private`
    case group
    case supergroup
    case channel
}

/// Telegram chat actions used by ``TelerouteContext/sendChatAction(_:to:)``.
public enum ChatAction: String, Sendable, Hashable {
    case typing
    case uploadPhoto = "upload_photo"
    case recordVideo = "record_video"
    case uploadVideo = "upload_video"
    case recordVoice = "record_voice"
    case uploadVoice = "upload_voice"
    case uploadDocument = "upload_document"
    case chooseSticker = "choose_sticker"
    case findLocation = "find_location"
    case recordVideoNote = "record_video_note"
    case uploadVideoNote = "upload_video_note"
}

/// A file argument for media-sending methods: an existing Telegram `file_id`,
/// an HTTP URL for Telegram to fetch, or raw bytes to upload.
public enum FileInput: Sendable, Hashable {
    case fileID(String)
    case url(String)
    case upload(filename: String, data: Data)

    /// The string form Telegram accepts inline (`file_id` or URL), when the
    /// value does not require a multipart upload.
    var stringValue: String? {
        switch self {
        case let .fileID(value), let .url(value): value
        case .upload: nil
        }
    }
}

// MARK: - Ergonomics over generated shapes

public extension ChatId {
    /// A numeric chat identifier.
    static func id(_ value: Int64) -> Self {
        .case1(value)
    }

    /// A `@username` of a supergroup or channel.
    static func username(_ value: String) -> Self {
        .case2(value)
    }

    /// The numeric identifier when this value carries one.
    var int64Value: Int64? {
        if case let .case1(value) = self { return value }
        return nil
    }
}

public extension ReplyMarkup {
    static func inline(_ markup: InlineKeyboardMarkup) -> Self {
        .InlineKeyboardMarkup(markup)
    }

    static func keyboard(_ markup: ReplyKeyboardMarkup) -> Self {
        .ReplyKeyboardMarkup(markup)
    }

    static func remove(_ markup: ReplyKeyboardRemove = .init(removeKeyboard: true)) -> Self {
        .ReplyKeyboardRemove(markup)
    }

    static func forceReply(_ markup: ForceReply = .init(forceReply: true)) -> Self {
        .ForceReply(markup)
    }
}

public extension InlineKeyboardMarkup {
    /// Creates a markup from rows of inline buttons.
    init(rows: [[InlineKeyboardButton]]) {
        self.init(inlineKeyboard: rows)
    }
}

public extension Chat {
    /// `Chat.type` decoded into the documented value set.
    var chatType: ChatType? {
        ChatType(rawValue: self._type)
    }
}

public extension MaybeInaccessibleMessage {
    /// The backing message when it is still accessible to the bot.
    ///
    /// Telegram marks inaccessible messages with `date == 0`. The two variants
    /// share their required fields, so an inaccessible message decodes as the
    /// `.Message` case; this accessor applies the documented `date` rule
    /// instead of trusting the decoded case.
    var accessibleMessage: Message? {
        switch self {
        case let .Message(message):
            message.date == 0 ? nil : message
        case .InaccessibleMessage:
            nil
        }
    }

    /// The chat the message belongs to, available for both variants.
    var chat: Chat {
        switch self {
        case let .Message(message): message.chat
        case let .InaccessibleMessage(message): message.chat
        }
    }
}

public extension MessageEntity {
    /// A `bot_command` entity covering `length` characters at `offset`.
    static func botCommand(offset: Int64, length: Int64) -> Self {
        .init(_type: "bot_command", offset: offset, length: length)
    }
}
