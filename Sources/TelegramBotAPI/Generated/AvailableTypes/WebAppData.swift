// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes data sent from a Web App to the bot.
public struct WebAppData: Codable, Hashable, Sendable {
    /// The data. Be aware that a bad client can send arbitrary data in this field.
    public var data: Swift.String

    /// Text of the *web_app* keyboard button from which the Web App was opened. Be aware that a
    /// bad client can send arbitrary data in this field.
    public var buttonText: Swift.String

    public init(
        data: Swift.String,
        buttonText: Swift.String
    ) {
        self.data = data
        self.buttonText = buttonText
    }

    public enum CodingKeys: String, CodingKey {
        case data
        case buttonText = "button_text"
    }
}
