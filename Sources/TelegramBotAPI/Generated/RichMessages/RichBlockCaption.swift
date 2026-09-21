// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Caption of a rich formatted block.
public struct RichBlockCaption: Codable, Hashable, Sendable {
    /// Block caption
    public var text: RichText

    /// *Optional*. Block credit which corresponds to the HTML tag <cite>
    public var credit: RichText?

    public init(
        text: RichText,
        credit: RichText? = nil
    ) {
        self.text = text
        self.credit = credit
    }

    public enum CodingKeys: String, CodingKey {
        case text
        case credit
    }
}
