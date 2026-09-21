// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The paid media is a photo.
public struct PaidMediaPhoto: Codable, Hashable, Sendable {
    /// Type of the paid media, always “photo”
    public var type: PaidMediaKind

    /// The photo
    public var photo: [PhotoSize]

    public init(
        type: PaidMediaKind = .photo,
        photo: [PhotoSize]
    ) {
        self.type = type
        self.photo = photo
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case photo
    }
}
