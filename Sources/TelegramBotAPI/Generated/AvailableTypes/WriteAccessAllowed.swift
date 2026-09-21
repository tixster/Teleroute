// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a service message about a user allowing a bot to write messages after
/// adding it to the attachment menu, launching a Web App from a link, or accepting an explicit
/// request from a Web App sent by the method requestWriteAccess.
public struct WriteAccessAllowed: Codable, Hashable, Sendable {
    /// *Optional*. *True*, if the access was granted after the user accepted an explicit
    /// request from a Web App sent by the method requestWriteAccess
    public var fromRequest: Swift.Bool?

    /// *Optional*. Name of the Web App, if the access was granted when the Web App was launched
    /// from a link
    public var webAppName: Swift.String?

    /// *Optional*. *True*, if the access was granted when the bot was added to the attachment
    /// or side menu
    public var fromAttachmentMenu: Swift.Bool?

    public init(
        fromRequest: Swift.Bool? = nil,
        webAppName: Swift.String? = nil,
        fromAttachmentMenu: Swift.Bool? = nil
    ) {
        self.fromRequest = fromRequest
        self.webAppName = webAppName
        self.fromAttachmentMenu = fromAttachmentMenu
    }

    public enum CodingKeys: String, CodingKey {
        case fromRequest = "from_request"
        case webAppName = "web_app_name"
        case fromAttachmentMenu = "from_attachment_menu"
    }
}
