// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents a voice message file to be sent.
public struct InputMediaVoiceNote: Codable, Hashable, Sendable {
    /// Type of the media, must be *voice_note*
    public var type: RichMessageInputMediaKind

    /// File to send. Pass a file_id to send a file that exists on the Telegram servers
    /// (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass
    /// "attach://<file_attach_name>" to upload a new one using multipart/form-data under
    /// <file_attach_name> name. More information on Sending Files »
    public var media: Swift.String

    /// *Optional*. Caption of the voice message to be sent, 0-1024 characters after entities
    /// parsing
    public var caption: Swift.String?

    /// *Optional*. Mode for parsing entities in the voice message caption. See formatting
    /// options for more details.
    public var parseMode: Swift.String?

    /// *Optional*. List of special entities that appear in the caption, which can be specified
    /// instead of *parse_mode*
    public var captionEntities: [MessageEntity]?

    /// *Optional*. Duration of the voice message in seconds
    public var duration: Swift.Int64?

    public init(
        type: RichMessageInputMediaKind = .voiceNote,
        media: Swift.String,
        caption: Swift.String? = nil,
        parseMode: Swift.String? = nil,
        captionEntities: [MessageEntity]? = nil,
        duration: Swift.Int64? = nil
    ) {
        self.type = type
        self.media = media
        self.caption = caption
        self.parseMode = parseMode
        self.captionEntities = captionEntities
        self.duration = duration
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case media
        case caption
        case parseMode = "parse_mode"
        case captionEntities = "caption_entities"
        case duration
    }
}
