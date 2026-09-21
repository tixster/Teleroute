// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// An item of a list to be sent.
public struct InputRichBlockListItem: Codable, Hashable, Sendable {
    /// The content of the item
    public var blocks: [InputRichBlock]

    /// *Optional*. Pass *True* if the item has a checkbox
    public var hasCheckbox: Swift.Bool?

    /// *Optional*. Pass *True* if the item has a checked checkbox
    public var isChecked: Swift.Bool?

    /// *Optional*. For ordered lists, the numeric value of the item label
    public var value: Swift.Int64?

    /// *Optional*. For ordered lists, the type of the item label; must be one of “a” for
    /// lowercase letters, “A” for uppercase letters, “i” for lowercase Roman numerals, “I” for
    /// uppercase Roman numerals, or “1” for decimal numbers
    public var type: RichBlockListItemType?

    public init(
        blocks: [InputRichBlock],
        hasCheckbox: Swift.Bool? = nil,
        isChecked: Swift.Bool? = nil,
        value: Swift.Int64? = nil,
        type: RichBlockListItemType? = nil
    ) {
        self.blocks = blocks
        self.hasCheckbox = hasCheckbox
        self.isChecked = isChecked
        self.value = value
        self.type = type
    }

    public enum CodingKeys: String, CodingKey {
        case blocks
        case hasCheckbox = "has_checkbox"
        case isChecked = "is_checked"
        case value
        case type
    }
}
