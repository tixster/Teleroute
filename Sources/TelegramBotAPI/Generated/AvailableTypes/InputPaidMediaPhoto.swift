// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The paid media to send is a photo.
public struct InputPaidMediaPhoto: Codable, Hashable, Sendable {
    /// Type of the media, must be *photo*
    public var type: InputPaidMediaKind

    /// File to send. Pass a file_id to send a file that exists on the Telegram servers
    /// (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass
    /// “attach://<file_attach_name>” to upload a new one using multipart/form-data under
    /// <file_attach_name> name. More information on Sending Files »
    public var media: Swift.String

    public init(
        type: InputPaidMediaKind = .photo,
        media: Swift.String
    ) {
        self.type = type
        self.media = media
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case media
    }
}
