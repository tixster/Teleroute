// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A block containing a list of buttons that are shown in one row, corresponding to the custom
/// HTML tag `<tg-button-row>`.
public struct InputRichBlockButtons: Codable, Hashable, Sendable {
    /// Type of the block, always “buttons”
    public var type: RichBlockKind

    /// List of 1-8 buttons to send
    public var buttons: [RichMessageButton]

    /// *Optional*. Horizontal alignment of the buttons. Currently, must be one of “left”,
    /// “center”, or “right”.
    public var align: RichBlockTableCellAlign?

    public init(
        type: RichBlockKind = .buttons,
        buttons: [RichMessageButton],
        align: RichBlockTableCellAlign? = nil
    ) {
        self.type = type
        self.buttons = buttons
        self.align = align
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case buttons
        case align
    }
}
