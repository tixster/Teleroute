// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes the options used for link preview generation.
public struct LinkPreviewOptions: Codable, Hashable, Sendable {
    /// *Optional*. *True*, if the link preview is disabled
    public var isDisabled: Swift.Bool?

    /// *Optional*. URL to use for the link preview. If empty, then the first URL found in the
    /// message text will be used.
    public var url: Swift.String?

    /// *Optional*. *True*, if the media in the link preview is supposed to be shrunk; ignored
    /// if the URL isn't explicitly specified or media size change isn't supported for the
    /// preview
    public var preferSmallMedia: Swift.Bool?

    /// *Optional*. *True*, if the media in the link preview is supposed to be enlarged; ignored
    /// if the URL isn't explicitly specified or media size change isn't supported for the
    /// preview
    public var preferLargeMedia: Swift.Bool?

    /// *Optional*. *True*, if the link preview must be shown above the message text; otherwise,
    /// the link preview will be shown below the message text
    public var showAboveText: Swift.Bool?

    public init(
        isDisabled: Swift.Bool? = nil,
        url: Swift.String? = nil,
        preferSmallMedia: Swift.Bool? = nil,
        preferLargeMedia: Swift.Bool? = nil,
        showAboveText: Swift.Bool? = nil
    ) {
        self.isDisabled = isDisabled
        self.url = url
        self.preferSmallMedia = preferSmallMedia
        self.preferLargeMedia = preferLargeMedia
        self.showAboveText = showAboveText
    }

    public enum CodingKeys: String, CodingKey {
        case isDisabled = "is_disabled"
        case url
        case preferSmallMedia = "prefer_small_media"
        case preferLargeMedia = "prefer_large_media"
        case showAboveText = "show_above_text"
    }
}
