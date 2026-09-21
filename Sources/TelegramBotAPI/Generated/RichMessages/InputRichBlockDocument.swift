// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A block with a general file, corresponding to the custom HTML tag `<tg-document>`.
public struct InputRichBlockDocument: Codable, Hashable, Sendable {
    /// Type of the block, always “document”
    public var type: RichBlockKind

    private var documentBox: _IndirectBox<InputMediaDocument>
    /// The document. Caption is ignored.
    public var document: InputMediaDocument {
        get { self.documentBox.value }
        set { self.documentBox = _IndirectBox(newValue) }
    }

    /// *Optional*. Caption of the block
    public var caption: RichBlockCaption?

    public init(
        type: RichBlockKind = .document,
        document: InputMediaDocument,
        caption: RichBlockCaption? = nil
    ) {
        self.type = type
        self.documentBox = _IndirectBox(document)
        self.caption = caption
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case documentBox = "document"
        case caption
    }
}
