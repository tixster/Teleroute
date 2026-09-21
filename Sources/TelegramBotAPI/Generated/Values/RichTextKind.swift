// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The `type` a ``RichText`` variant carries.
public enum RichTextKind: RawRepresentable, Codable, Hashable, Sendable {
    case bold
    case italic
    case underline
    case strikethrough
    case spoiler
    case dateTime
    case textMention
    case `subscript`
    case superscript
    case marked
    case code
    case customEmoji
    case mathematicalExpression
    case url
    case emailAddress
    case phoneNumber
    case bankCardNumber
    case mention
    case hashtag
    case cashtag
    case botCommand
    case button
    case anchor
    case anchorLink
    case reference
    case referenceLink
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .bold: "bold"
        case .italic: "italic"
        case .underline: "underline"
        case .strikethrough: "strikethrough"
        case .spoiler: "spoiler"
        case .dateTime: "date_time"
        case .textMention: "text_mention"
        case .subscript: "subscript"
        case .superscript: "superscript"
        case .marked: "marked"
        case .code: "code"
        case .customEmoji: "custom_emoji"
        case .mathematicalExpression: "mathematical_expression"
        case .url: "url"
        case .emailAddress: "email_address"
        case .phoneNumber: "phone_number"
        case .bankCardNumber: "bank_card_number"
        case .mention: "mention"
        case .hashtag: "hashtag"
        case .cashtag: "cashtag"
        case .botCommand: "bot_command"
        case .button: "button"
        case .anchor: "anchor"
        case .anchorLink: "anchor_link"
        case .reference: "reference"
        case .referenceLink: "reference_link"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "bold": self = .bold
        case "italic": self = .italic
        case "underline": self = .underline
        case "strikethrough": self = .strikethrough
        case "spoiler": self = .spoiler
        case "date_time": self = .dateTime
        case "text_mention": self = .textMention
        case "subscript": self = .subscript
        case "superscript": self = .superscript
        case "marked": self = .marked
        case "code": self = .code
        case "custom_emoji": self = .customEmoji
        case "mathematical_expression": self = .mathematicalExpression
        case "url": self = .url
        case "email_address": self = .emailAddress
        case "phone_number": self = .phoneNumber
        case "bank_card_number": self = .bankCardNumber
        case "mention": self = .mention
        case "hashtag": self = .hashtag
        case "cashtag": self = .cashtag
        case "bot_command": self = .botCommand
        case "button": self = .button
        case "anchor": self = .anchor
        case "anchor_link": self = .anchorLink
        case "reference": self = .reference
        case "reference_link": self = .referenceLink
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
    public static let documentedCases: [RichTextKind] = [
        .bold,
        .italic,
        .underline,
        .strikethrough,
        .spoiler,
        .dateTime,
        .textMention,
        .subscript,
        .superscript,
        .marked,
        .code,
        .customEmoji,
        .mathematicalExpression,
        .url,
        .emailAddress,
        .phoneNumber,
        .bankCardNumber,
        .mention,
        .hashtag,
        .cashtag,
        .botCommand,
        .button,
        .anchor,
        .anchorLink,
        .reference,
        .referenceLink,
    ]
}
