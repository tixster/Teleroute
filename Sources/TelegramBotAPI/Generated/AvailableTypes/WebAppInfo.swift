// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a Web App.
public struct WebAppInfo: Codable, Hashable, Sendable {
    /// An HTTPS URL of a Web App to be opened with additional data as specified in Initializing
    /// Web Apps
    public var url: Swift.String

    public init(
        url: Swift.String
    ) {
        self.url = url
    }

    public enum CodingKeys: String, CodingKey {
        case url
    }
}
