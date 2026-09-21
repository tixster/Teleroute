// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a block in a rich formatted message. Currently, it can be any of the
/// following types:
public enum RichBlock: Codable, Hashable, Sendable {
    case paragraph(RichBlockParagraph)
    case heading(RichBlockSectionHeading)
    case pre(RichBlockPreformatted)
    case footer(RichBlockFooter)
    case divider(RichBlockDivider)
    case mathematicalExpression(RichBlockMathematicalExpression)
    case anchor(RichBlockAnchor)
    case list(RichBlockList)
    case blockquote(RichBlockBlockQuotation)
    case expandableBlockquote(RichBlockExpandableBlockQuotation)
    case pullquote(RichBlockPullQuotation)
    case collage(RichBlockCollage)
    case slideshow(RichBlockSlideshow)
    case table(RichBlockTable)
    case details(RichBlockDetails)
    case map(RichBlockMap)
    case buttons(RichBlockButtons)
    case animation(RichBlockAnimation)
    case audio(RichBlockAudio)
    case document(RichBlockDocument)
    case photo(RichBlockPhoto)
    case video(RichBlockVideo)
    case voiceNote(RichBlockVoiceNote)
    case thinking(RichBlockThinking)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "paragraph":
            self = .paragraph(try RichBlockParagraph(from: decoder))
        case "heading":
            self = .heading(try RichBlockSectionHeading(from: decoder))
        case "pre":
            self = .pre(try RichBlockPreformatted(from: decoder))
        case "footer":
            self = .footer(try RichBlockFooter(from: decoder))
        case "divider":
            self = .divider(try RichBlockDivider(from: decoder))
        case "mathematical_expression":
            self = .mathematicalExpression(try RichBlockMathematicalExpression(from: decoder))
        case "anchor":
            self = .anchor(try RichBlockAnchor(from: decoder))
        case "list":
            self = .list(try RichBlockList(from: decoder))
        case "blockquote":
            self = .blockquote(try RichBlockBlockQuotation(from: decoder))
        case "expandable_blockquote":
            self = .expandableBlockquote(try RichBlockExpandableBlockQuotation(from: decoder))
        case "pullquote":
            self = .pullquote(try RichBlockPullQuotation(from: decoder))
        case "collage":
            self = .collage(try RichBlockCollage(from: decoder))
        case "slideshow":
            self = .slideshow(try RichBlockSlideshow(from: decoder))
        case "table":
            self = .table(try RichBlockTable(from: decoder))
        case "details":
            self = .details(try RichBlockDetails(from: decoder))
        case "map":
            self = .map(try RichBlockMap(from: decoder))
        case "buttons":
            self = .buttons(try RichBlockButtons(from: decoder))
        case "animation":
            self = .animation(try RichBlockAnimation(from: decoder))
        case "audio":
            self = .audio(try RichBlockAudio(from: decoder))
        case "document":
            self = .document(try RichBlockDocument(from: decoder))
        case "photo":
            self = .photo(try RichBlockPhoto(from: decoder))
        case "video":
            self = .video(try RichBlockVideo(from: decoder))
        case "voice_note":
            self = .voiceNote(try RichBlockVoiceNote(from: decoder))
        case "thinking":
            self = .thinking(try RichBlockThinking(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown RichBlock type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .paragraph(value):
            try value.encode(to: encoder)
        case let .heading(value):
            try value.encode(to: encoder)
        case let .pre(value):
            try value.encode(to: encoder)
        case let .footer(value):
            try value.encode(to: encoder)
        case let .divider(value):
            try value.encode(to: encoder)
        case let .mathematicalExpression(value):
            try value.encode(to: encoder)
        case let .anchor(value):
            try value.encode(to: encoder)
        case let .list(value):
            try value.encode(to: encoder)
        case let .blockquote(value):
            try value.encode(to: encoder)
        case let .expandableBlockquote(value):
            try value.encode(to: encoder)
        case let .pullquote(value):
            try value.encode(to: encoder)
        case let .collage(value):
            try value.encode(to: encoder)
        case let .slideshow(value):
            try value.encode(to: encoder)
        case let .table(value):
            try value.encode(to: encoder)
        case let .details(value):
            try value.encode(to: encoder)
        case let .map(value):
            try value.encode(to: encoder)
        case let .buttons(value):
            try value.encode(to: encoder)
        case let .animation(value):
            try value.encode(to: encoder)
        case let .audio(value):
            try value.encode(to: encoder)
        case let .document(value):
            try value.encode(to: encoder)
        case let .photo(value):
            try value.encode(to: encoder)
        case let .video(value):
            try value.encode(to: encoder)
        case let .voiceNote(value):
            try value.encode(to: encoder)
        case let .thinking(value):
            try value.encode(to: encoder)
        }
    }
}
