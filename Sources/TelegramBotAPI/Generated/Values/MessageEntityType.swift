// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Type of the entity. Currently, can be “mention” (`@username`), “hashtag” (`#hashtag` or
/// `#hashtag@chatusername`), “cashtag” (`$USD` or `$USD@chatusername`), “bot_command”
/// (`/start@jobs_bot`), “url” (`https://telegram.org`), “email” (`do-not-reply@telegram.org`),
/// “phone_number” (`+1-212-555-0123`), “bold” (**bold text**), “italic” (*italic text*),
/// “underline” (underlined text), “strikethrough” (strikethrough text), “spoiler” (spoiler
/// message), “blockquote” (block quotation), “expandable_blockquote” (collapsed-by-default
/// block quotation), “code” (monowidth string), “pre” (monowidth block), “text_link” (for
/// clickable text URLs), “text_mention” (for users [without
/// usernames](https://telegram.org/blog/edit#new-mentions)), “custom_emoji” (for inline custom
/// emoji stickers), or “date_time” (for formatted date and time).
public enum MessageEntityType: RawRepresentable, Codable, Hashable, Sendable {
    case mention
    case hashtag
    case cashtag
    case botCommand
    case url
    case email
    case phoneNumber
    case bold
    case italic
    case underline
    case strikethrough
    case spoiler
    case blockquote
    case expandableBlockquote
    case code
    case pre
    case textLink
    case textMention
    case customEmoji
    case dateTime
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .mention: "mention"
        case .hashtag: "hashtag"
        case .cashtag: "cashtag"
        case .botCommand: "bot_command"
        case .url: "url"
        case .email: "email"
        case .phoneNumber: "phone_number"
        case .bold: "bold"
        case .italic: "italic"
        case .underline: "underline"
        case .strikethrough: "strikethrough"
        case .spoiler: "spoiler"
        case .blockquote: "blockquote"
        case .expandableBlockquote: "expandable_blockquote"
        case .code: "code"
        case .pre: "pre"
        case .textLink: "text_link"
        case .textMention: "text_mention"
        case .customEmoji: "custom_emoji"
        case .dateTime: "date_time"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "mention": self = .mention
        case "hashtag": self = .hashtag
        case "cashtag": self = .cashtag
        case "bot_command": self = .botCommand
        case "url": self = .url
        case "email": self = .email
        case "phone_number": self = .phoneNumber
        case "bold": self = .bold
        case "italic": self = .italic
        case "underline": self = .underline
        case "strikethrough": self = .strikethrough
        case "spoiler": self = .spoiler
        case "blockquote": self = .blockquote
        case "expandable_blockquote": self = .expandableBlockquote
        case "code": self = .code
        case "pre": self = .pre
        case "text_link": self = .textLink
        case "text_mention": self = .textMention
        case "custom_emoji": self = .customEmoji
        case "date_time": self = .dateTime
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
    public static let documentedCases: [MessageEntityType] = [
        .mention,
        .hashtag,
        .cashtag,
        .botCommand,
        .url,
        .email,
        .phoneNumber,
        .bold,
        .italic,
        .underline,
        .strikethrough,
        .spoiler,
        .blockquote,
        .expandableBlockquote,
        .code,
        .pre,
        .textLink,
        .textMention,
        .customEmoji,
        .dateTime,
    ]
}
