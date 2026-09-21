// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a menu button, which launches a Web App.
public struct MenuButtonWebApp: Codable, Hashable, Sendable {
    /// Type of the button, must be *web_app*
    public var type: MenuButtonKind

    /// Text on the button
    public var text: Swift.String

    /// Description of the Web App that will be launched when the user presses the button. The
    /// Web App will be able to send an arbitrary message on behalf of the user using the method
    /// `answerWebAppQuery`. Alternatively, a `t.me` link to a Web App of the bot can be
    /// specified in the object instead of the Web App's URL, in which case the Web App will be
    /// opened as if the user pressed the link.
    public var webApp: WebAppInfo

    public init(
        type: MenuButtonKind = .webApp,
        text: Swift.String,
        webApp: WebAppInfo
    ) {
        self.type = type
        self.text = text
        self.webApp = webApp
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case text
        case webApp = "web_app"
    }
}
