// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains information about a paid media purchase.
public struct PaidMediaPurchased: Codable, Hashable, Sendable {
    private var fromBox: _IndirectBox<User>
    /// User who purchased the media
    public var from: User {
        get { self.fromBox.value }
        set { self.fromBox = _IndirectBox(newValue) }
    }

    /// Bot-specified paid media payload
    public var paidMediaPayload: Swift.String

    public init(
        from: User,
        paidMediaPayload: Swift.String
    ) {
        self.fromBox = _IndirectBox(from)
        self.paidMediaPayload = paidMediaPayload
    }

    public enum CodingKeys: String, CodingKey {
        case fromBox = "from"
        case paidMediaPayload = "paid_media_payload"
    }
}
