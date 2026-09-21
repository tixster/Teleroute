// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a service message about a video chat ended in the chat.
public struct VideoChatEnded: Codable, Hashable, Sendable {
    /// Video chat duration in seconds
    public var duration: Swift.Int64

    public init(
        duration: Swift.Int64
    ) {
        self.duration = duration
    }

    public enum CodingKeys: String, CodingKey {
        case duration
    }
}
