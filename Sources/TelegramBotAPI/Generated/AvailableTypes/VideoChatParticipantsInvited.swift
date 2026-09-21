// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a service message about new members invited to a video chat.
public struct VideoChatParticipantsInvited: Codable, Hashable, Sendable {
    /// New members that were invited to the video chat
    public var users: [User]

    public init(
        users: [User]
    ) {
        self.users = users
    }

    public enum CodingKeys: String, CodingKey {
        case users
    }
}
