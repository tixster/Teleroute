// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The paid media to send is a live photo.
public struct InputPaidMediaLivePhoto: Codable, Hashable, Sendable {
    /// Type of the media, must be *live_photo*
    public var type: InputPaidMediaKind

    /// Video of the live photo to send. Pass a file_id to send a file that exists on the
    /// Telegram servers (recommended) or pass “attach://<file_attach_name>” to upload a new one
    /// using multipart/form-data under <file_attach_name> name. More information on Sending
    /// Files ». Sending live photos by a URL is currently unsupported.
    public var media: Swift.String

    /// The static photo to send. Pass a file_id to send a file that exists on the Telegram
    /// servers (recommended) or pass “attach://<file_attach_name>” to upload a new one using
    /// multipart/form-data under <file_attach_name> name. More information on Sending Files ».
    /// Sending live photos by a URL is currently unsupported.
    public var photo: Swift.String

    public init(
        type: InputPaidMediaKind = .livePhoto,
        media: Swift.String,
        photo: Swift.String
    ) {
        self.type = type
        self.media = media
        self.photo = photo
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case media
        case photo
    }
}
