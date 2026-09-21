// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a rich formatted text. Currently, it can be either a String for plain
/// text, an Array of ``RichText``, or any of the following types:
public indirect enum RichText: Codable, Hashable, Sendable {
    case text(Swift.String)
    case sequence([RichText])
    case bold(RichTextBold)
    case italic(RichTextItalic)
    case underline(RichTextUnderline)
    case strikethrough(RichTextStrikethrough)
    case spoiler(RichTextSpoiler)
    case dateTime(RichTextDateTime)
    case textMention(RichTextTextMention)
    case _subscript(RichTextSubscript)
    case superscript(RichTextSuperscript)
    case marked(RichTextMarked)
    case code(RichTextCode)
    case customEmoji(RichTextCustomEmoji)
    case mathematicalExpression(RichTextMathematicalExpression)
    case url(RichTextUrl)
    case emailAddress(RichTextEmailAddress)
    case phoneNumber(RichTextPhoneNumber)
    case bankCardNumber(RichTextBankCardNumber)
    case mention(RichTextMention)
    case hashtag(RichTextHashtag)
    case cashtag(RichTextCashtag)
    case botCommand(RichTextBotCommand)
    case button(RichTextButton)
    case anchor(RichTextAnchor)
    case anchorLink(RichTextAnchorLink)
    case reference(RichTextReference)
    case referenceLink(RichTextReferenceLink)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        if let value = try? decoder.singleValueContainer().decode(Swift.String.self) {
            self = .text(value)
            return
        }
        if let value = try? decoder.singleValueContainer().decode([RichText].self) {
            self = .sequence(value)
            return
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "bold":
            self = .bold(try RichTextBold(from: decoder))
        case "italic":
            self = .italic(try RichTextItalic(from: decoder))
        case "underline":
            self = .underline(try RichTextUnderline(from: decoder))
        case "strikethrough":
            self = .strikethrough(try RichTextStrikethrough(from: decoder))
        case "spoiler":
            self = .spoiler(try RichTextSpoiler(from: decoder))
        case "date_time":
            self = .dateTime(try RichTextDateTime(from: decoder))
        case "text_mention":
            self = .textMention(try RichTextTextMention(from: decoder))
        case "subscript":
            self = ._subscript(try RichTextSubscript(from: decoder))
        case "superscript":
            self = .superscript(try RichTextSuperscript(from: decoder))
        case "marked":
            self = .marked(try RichTextMarked(from: decoder))
        case "code":
            self = .code(try RichTextCode(from: decoder))
        case "custom_emoji":
            self = .customEmoji(try RichTextCustomEmoji(from: decoder))
        case "mathematical_expression":
            self = .mathematicalExpression(try RichTextMathematicalExpression(from: decoder))
        case "url":
            self = .url(try RichTextUrl(from: decoder))
        case "email_address":
            self = .emailAddress(try RichTextEmailAddress(from: decoder))
        case "phone_number":
            self = .phoneNumber(try RichTextPhoneNumber(from: decoder))
        case "bank_card_number":
            self = .bankCardNumber(try RichTextBankCardNumber(from: decoder))
        case "mention":
            self = .mention(try RichTextMention(from: decoder))
        case "hashtag":
            self = .hashtag(try RichTextHashtag(from: decoder))
        case "cashtag":
            self = .cashtag(try RichTextCashtag(from: decoder))
        case "bot_command":
            self = .botCommand(try RichTextBotCommand(from: decoder))
        case "button":
            self = .button(try RichTextButton(from: decoder))
        case "anchor":
            self = .anchor(try RichTextAnchor(from: decoder))
        case "anchor_link":
            self = .anchorLink(try RichTextAnchorLink(from: decoder))
        case "reference":
            self = .reference(try RichTextReference(from: decoder))
        case "reference_link":
            self = .referenceLink(try RichTextReferenceLink(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown RichText type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .text(value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case let .sequence(value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case let .bold(value):
            try value.encode(to: encoder)
        case let .italic(value):
            try value.encode(to: encoder)
        case let .underline(value):
            try value.encode(to: encoder)
        case let .strikethrough(value):
            try value.encode(to: encoder)
        case let .spoiler(value):
            try value.encode(to: encoder)
        case let .dateTime(value):
            try value.encode(to: encoder)
        case let .textMention(value):
            try value.encode(to: encoder)
        case let ._subscript(value):
            try value.encode(to: encoder)
        case let .superscript(value):
            try value.encode(to: encoder)
        case let .marked(value):
            try value.encode(to: encoder)
        case let .code(value):
            try value.encode(to: encoder)
        case let .customEmoji(value):
            try value.encode(to: encoder)
        case let .mathematicalExpression(value):
            try value.encode(to: encoder)
        case let .url(value):
            try value.encode(to: encoder)
        case let .emailAddress(value):
            try value.encode(to: encoder)
        case let .phoneNumber(value):
            try value.encode(to: encoder)
        case let .bankCardNumber(value):
            try value.encode(to: encoder)
        case let .mention(value):
            try value.encode(to: encoder)
        case let .hashtag(value):
            try value.encode(to: encoder)
        case let .cashtag(value):
            try value.encode(to: encoder)
        case let .botCommand(value):
            try value.encode(to: encoder)
        case let .button(value):
            try value.encode(to: encoder)
        case let .anchor(value):
            try value.encode(to: encoder)
        case let .anchorLink(value):
            try value.encode(to: encoder)
        case let .reference(value):
            try value.encode(to: encoder)
        case let .referenceLink(value):
            try value.encode(to: encoder)
        }
    }
}
