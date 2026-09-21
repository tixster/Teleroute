// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The reaction is paid.
public struct ReactionTypePaid: Codable, Hashable, Sendable {
    /// Type of the reaction, always “paid”
    public var type: ReactionTypeKind

    public init(
        type: ReactionTypeKind = .paid
    ) {
        self.type = type
    }

    public enum CodingKeys: String, CodingKey {
        case type
    }
}
