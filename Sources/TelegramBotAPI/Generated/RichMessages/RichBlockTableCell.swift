// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Cell in a table.
public struct RichBlockTableCell: Codable, Hashable, Sendable {
    /// *Optional*. Text in the cell. If omitted, then the cell is invisible.
    public var text: RichText?

    /// *Optional*. *True*, if the cell is a header cell
    public var isHeader: Swift.Bool?

    /// *Optional*. The number of columns the cell spans if it is bigger than 1
    public var colspan: Swift.Int64?

    /// *Optional*. The number of rows the cell spans if it is bigger than 1
    public var rowspan: Swift.Int64?

    /// Horizontal cell content alignment. Currently, must be one of “left”, “center”, or
    /// “right”.
    public var align: RichBlockTableCellAlign

    /// Vertical cell content alignment. Currently, must be one of “top”, “middle”, or “bottom”.
    public var valign: RichBlockTableCellValign

    public init(
        text: RichText? = nil,
        isHeader: Swift.Bool? = nil,
        colspan: Swift.Int64? = nil,
        rowspan: Swift.Int64? = nil,
        align: RichBlockTableCellAlign,
        valign: RichBlockTableCellValign
    ) {
        self.text = text
        self.isHeader = isHeader
        self.colspan = colspan
        self.rowspan = rowspan
        self.align = align
        self.valign = valign
    }

    public enum CodingKeys: String, CodingKey {
        case text
        case isHeader = "is_header"
        case colspan
        case rowspan
        case align
        case valign
    }
}
