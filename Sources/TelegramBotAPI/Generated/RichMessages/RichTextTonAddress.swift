// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// An address in the TON blockchain.
public struct RichTextTonAddress: Codable, Hashable, Sendable {
    /// Type of the rich text, always “ton_address”
    public var type: RichTextKind

    /// Text of the address
    public var text: RichText

    /// The address
    public var address: Swift.String

    public init(
        type: RichTextKind = .tonAddress,
        text: RichText,
        address: Swift.String
    ) {
        self.type = type
        self.text = text
        self.address = address
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
        case address
    }
}
