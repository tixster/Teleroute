// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a service message about a video chat scheduled in the chat.
public struct VideoChatScheduled: Codable, Hashable, Sendable {
    /// Point in time (Unix timestamp) when the video chat is supposed to be started by a chat
    /// administrator
    public var startDate: Swift.Int64

    public init(
        startDate: Swift.Int64
    ) {
        self.startDate = startDate
    }

    public enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
    }
}
