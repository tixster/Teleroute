// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The `type` a ``RichBlock`` variant carries.
///
/// Used by RichBlock.type, InputRichBlock.type.
public enum RichBlockKind: RawRepresentable, Codable, Hashable, Sendable {
    case paragraph
    case heading
    case pre
    case footer
    case divider
    case mathematicalExpression
    case anchor
    case list
    case blockquote
    case expandableBlockquote
    case pullquote
    case collage
    case slideshow
    case table
    case details
    case map
    case buttons
    case animation
    case audio
    case document
    case photo
    case video
    case voiceNote
    case thinking
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .paragraph: "paragraph"
        case .heading: "heading"
        case .pre: "pre"
        case .footer: "footer"
        case .divider: "divider"
        case .mathematicalExpression: "mathematical_expression"
        case .anchor: "anchor"
        case .list: "list"
        case .blockquote: "blockquote"
        case .expandableBlockquote: "expandable_blockquote"
        case .pullquote: "pullquote"
        case .collage: "collage"
        case .slideshow: "slideshow"
        case .table: "table"
        case .details: "details"
        case .map: "map"
        case .buttons: "buttons"
        case .animation: "animation"
        case .audio: "audio"
        case .document: "document"
        case .photo: "photo"
        case .video: "video"
        case .voiceNote: "voice_note"
        case .thinking: "thinking"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "paragraph": self = .paragraph
        case "heading": self = .heading
        case "pre": self = .pre
        case "footer": self = .footer
        case "divider": self = .divider
        case "mathematical_expression": self = .mathematicalExpression
        case "anchor": self = .anchor
        case "list": self = .list
        case "blockquote": self = .blockquote
        case "expandable_blockquote": self = .expandableBlockquote
        case "pullquote": self = .pullquote
        case "collage": self = .collage
        case "slideshow": self = .slideshow
        case "table": self = .table
        case "details": self = .details
        case "map": self = .map
        case "buttons": self = .buttons
        case "animation": self = .animation
        case "audio": self = .audio
        case "document": self = .document
        case "photo": self = .photo
        case "video": self = .video
        case "voice_note": self = .voiceNote
        case "thinking": self = .thinking
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
    public static let documentedCases: [RichBlockKind] = [
        .paragraph,
        .heading,
        .pre,
        .footer,
        .divider,
        .mathematicalExpression,
        .anchor,
        .list,
        .blockquote,
        .expandableBlockquote,
        .pullquote,
        .collage,
        .slideshow,
        .table,
        .details,
        .map,
        .buttons,
        .animation,
        .audio,
        .document,
        .photo,
        .video,
        .voiceNote,
        .thinking,
    ]
}
