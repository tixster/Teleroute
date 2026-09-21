// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The paid media isn't available before the payment.
public struct PaidMediaPreview: Codable, Hashable, Sendable {
    /// Type of the paid media, always “preview”
    public var type: PaidMediaKind

    /// *Optional*. Media width as defined by the sender
    public var width: Swift.Int64?

    /// *Optional*. Media height as defined by the sender
    public var height: Swift.Int64?

    /// *Optional*. Duration of the media in seconds as defined by the sender
    public var duration: Swift.Int64?

    public init(
        type: PaidMediaKind = .preview,
        width: Swift.Int64? = nil,
        height: Swift.Int64? = nil,
        duration: Swift.Int64? = nil
    ) {
        self.type = type
        self.width = width
        self.height = height
        self.duration = duration
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case width
        case height
        case duration
    }
}
