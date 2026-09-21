// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents an inline keyboard button that copies specified text to the
/// clipboard.
public struct CopyTextButton: Codable, Hashable, Sendable {
    /// The text to be copied to the clipboard; 1-256 characters
    public var text: Swift.String

    public init(
        text: Swift.String
    ) {
        self.text = text
    }

    public enum CodingKeys: String, CodingKey {
        case text
    }
}
