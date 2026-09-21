// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A text with a bank card number.
public struct RichTextBankCardNumber: Codable, Hashable, Sendable {
    /// Type of the rich text, always “bank_card_number”
    public var type: RichTextKind

    /// The text
    public var text: RichText

    /// The bank card number
    public var bankCardNumber: Swift.String

    public init(
        type: RichTextKind = .bankCardNumber,
        text: RichText,
        bankCardNumber: Swift.String
    ) {
        self.type = type
        self.text = text
        self.bankCardNumber = bankCardNumber
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
        case bankCardNumber = "bank_card_number"
    }
}
