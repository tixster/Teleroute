// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents type of a poll, which is allowed to be created and sent when the
/// corresponding button is pressed.
public struct KeyboardButtonPollType: Codable, Hashable, Sendable {
    /// *Optional*. If *quiz* is passed, the user will be allowed to create only polls in the
    /// quiz mode. If *regular* is passed, only regular polls will be allowed. Otherwise, the
    /// user will be allowed to create a poll of any type.
    public var type: Swift.String?

    public init(
        type: Swift.String? = nil
    ) {
        self.type = type
    }

    public enum CodingKeys: String, CodingKey {
        case type
    }
}
