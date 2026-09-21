// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The paid media is a live photo.
public struct PaidMediaLivePhoto: Codable, Hashable, Sendable {
    /// Type of the paid media, always “live_photo”
    public var type: PaidMediaKind

    /// The photo
    public var livePhoto: LivePhoto

    public init(
        type: PaidMediaKind = .livePhoto,
        livePhoto: LivePhoto
    ) {
        self.type = type
        self.livePhoto = livePhoto
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case livePhoto = "live_photo"
    }
}
