// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a general file to be sent.
public struct InputMediaDocument: Codable, Hashable, Sendable {
    /// Type of the media, must be *document*
    public var type: InputPollMediaKind

    /// File to send. Pass a file_id to send a file that exists on the Telegram servers
    /// (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass
    /// “attach://<file_attach_name>” to upload a new one using multipart/form-data under
    /// <file_attach_name> name. More information on Sending Files »
    public var media: Swift.String

    /// *Optional*. Thumbnail of the file sent; can be ignored if thumbnail generation for the
    /// file is supported server-side. The thumbnail should be in JPEG format and less than 200
    /// kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is
    /// not uploaded using multipart/form-data. Thumbnails can't be reused and can be only
    /// uploaded as a new file, so you can pass “attach://<file_attach_name>” if the thumbnail
    /// was uploaded using multipart/form-data under <file_attach_name>. More information on
    /// Sending Files »
    public var thumbnail: Swift.String?

    /// *Optional*. Caption of the document to be sent, 0-1024 characters after entities parsing
    public var caption: Swift.String?

    /// *Optional*. Mode for parsing entities in the document caption. See formatting options
    /// for more details.
    public var parseMode: Swift.String?

    /// *Optional*. List of special entities that appear in the caption, which can be specified
    /// instead of *parse_mode*
    public var captionEntities: [MessageEntity]?

    /// *Optional*. Disables automatic server-side content type detection for files uploaded
    /// using multipart/form-data. Always *True*, if the document is sent as part of an album.
    public var disableContentTypeDetection: Swift.Bool?

    public init(
        type: InputPollMediaKind = .document,
        media: Swift.String,
        thumbnail: Swift.String? = nil,
        caption: Swift.String? = nil,
        parseMode: Swift.String? = nil,
        captionEntities: [MessageEntity]? = nil,
        disableContentTypeDetection: Swift.Bool? = nil
    ) {
        self.type = type
        self.media = media
        self.thumbnail = thumbnail
        self.caption = caption
        self.parseMode = parseMode
        self.captionEntities = captionEntities
        self.disableContentTypeDetection = disableContentTypeDetection
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case media
        case thumbnail
        case caption
        case parseMode = "parse_mode"
        case captionEntities = "caption_entities"
        case disableContentTypeDetection = "disable_content_type_detection"
    }
}
