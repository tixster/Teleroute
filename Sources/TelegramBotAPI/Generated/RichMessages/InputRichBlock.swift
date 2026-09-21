// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a block in a rich formatted message to be sent. Currently, it can be
/// any of the following types:
public enum InputRichBlock: Codable, Hashable, Sendable {
    case paragraph(InputRichBlockParagraph)
    case heading(InputRichBlockSectionHeading)
    case pre(InputRichBlockPreformatted)
    case footer(InputRichBlockFooter)
    case divider(InputRichBlockDivider)
    case mathematicalExpression(InputRichBlockMathematicalExpression)
    case anchor(InputRichBlockAnchor)
    case list(InputRichBlockList)
    case blockquote(InputRichBlockBlockQuotation)
    case expandableBlockquote(InputRichBlockExpandableBlockQuotation)
    case pullquote(InputRichBlockPullQuotation)
    case collage(InputRichBlockCollage)
    case slideshow(InputRichBlockSlideshow)
    case table(InputRichBlockTable)
    case details(InputRichBlockDetails)
    case map(InputRichBlockMap)
    case buttons(InputRichBlockButtons)
    case animation(InputRichBlockAnimation)
    case audio(InputRichBlockAudio)
    case document(InputRichBlockDocument)
    case photo(InputRichBlockPhoto)
    case video(InputRichBlockVideo)
    case voiceNote(InputRichBlockVoiceNote)
    case thinking(InputRichBlockThinking)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "paragraph":
            self = .paragraph(try InputRichBlockParagraph(from: decoder))
        case "heading":
            self = .heading(try InputRichBlockSectionHeading(from: decoder))
        case "pre":
            self = .pre(try InputRichBlockPreformatted(from: decoder))
        case "footer":
            self = .footer(try InputRichBlockFooter(from: decoder))
        case "divider":
            self = .divider(try InputRichBlockDivider(from: decoder))
        case "mathematical_expression":
            self = .mathematicalExpression(try InputRichBlockMathematicalExpression(from: decoder))
        case "anchor":
            self = .anchor(try InputRichBlockAnchor(from: decoder))
        case "list":
            self = .list(try InputRichBlockList(from: decoder))
        case "blockquote":
            self = .blockquote(try InputRichBlockBlockQuotation(from: decoder))
        case "expandable_blockquote":
            self = .expandableBlockquote(try InputRichBlockExpandableBlockQuotation(from: decoder))
        case "pullquote":
            self = .pullquote(try InputRichBlockPullQuotation(from: decoder))
        case "collage":
            self = .collage(try InputRichBlockCollage(from: decoder))
        case "slideshow":
            self = .slideshow(try InputRichBlockSlideshow(from: decoder))
        case "table":
            self = .table(try InputRichBlockTable(from: decoder))
        case "details":
            self = .details(try InputRichBlockDetails(from: decoder))
        case "map":
            self = .map(try InputRichBlockMap(from: decoder))
        case "buttons":
            self = .buttons(try InputRichBlockButtons(from: decoder))
        case "animation":
            self = .animation(try InputRichBlockAnimation(from: decoder))
        case "audio":
            self = .audio(try InputRichBlockAudio(from: decoder))
        case "document":
            self = .document(try InputRichBlockDocument(from: decoder))
        case "photo":
            self = .photo(try InputRichBlockPhoto(from: decoder))
        case "video":
            self = .video(try InputRichBlockVideo(from: decoder))
        case "voice_note":
            self = .voiceNote(try InputRichBlockVoiceNote(from: decoder))
        case "thinking":
            self = .thinking(try InputRichBlockThinking(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown InputRichBlock type '\(other)'")
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
