// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A block with an anchor, corresponding to the HTML tag `<a>` with the attribute `name`.
public struct RichBlockAnchor: Codable, Hashable, Sendable {
    /// Type of the block, always “anchor”
    public var type: RichBlockKind

    /// The name of the anchor
    public var name: Swift.String

    public init(
        type: RichBlockKind = .anchor,
        name: Swift.String
    ) {
        self.type = type
        self.name = name
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case name
    }
}
