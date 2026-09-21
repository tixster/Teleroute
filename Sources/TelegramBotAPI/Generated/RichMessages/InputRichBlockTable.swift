// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A table, corresponding to the HTML tag `<table>`.
public struct InputRichBlockTable: Codable, Hashable, Sendable {
    /// Type of the block, always “table”
    public var type: RichBlockKind

    /// Cells of the table
    public var cells: [[RichBlockTableCell]]

    /// *Optional*. Pass *True* if the table has borders
    public var isBordered: Swift.Bool?

    /// *Optional*. Pass *True* if the table is striped
    public var isStriped: Swift.Bool?

    /// *Optional*. Pass *True* if table cells must have smaller indents
    public var isCompact: Swift.Bool?

    /// *Optional*. Caption of the table
    public var caption: RichText?

    public init(
        type: RichBlockKind = .table,
        cells: [[RichBlockTableCell]],
        isBordered: Swift.Bool? = nil,
        isStriped: Swift.Bool? = nil,
        isCompact: Swift.Bool? = nil,
        caption: RichText? = nil
    ) {
        self.type = type
        self.cells = cells
        self.isBordered = isBordered
        self.isStriped = isStriped
        self.isCompact = isCompact
        self.caption = caption
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case cells
        case isBordered = "is_bordered"
        case isStriped = "is_striped"
        case isCompact = "is_compact"
        case caption
    }
}
