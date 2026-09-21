// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents the audios displayed on a user's profile.
public struct UserProfileAudios: Codable, Hashable, Sendable {
    /// Total number of profile audios for the target user
    public var totalCount: Swift.Int64

    /// Requested profile audios
    public var audios: [Audio]

    public init(
        totalCount: Swift.Int64,
        audios: [Audio]
    ) {
        self.totalCount = totalCount
        self.audios = audios
    }

    public enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case audios
    }
}
