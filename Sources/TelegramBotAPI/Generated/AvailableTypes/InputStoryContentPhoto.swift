// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a photo to post as a story.
public struct InputStoryContentPhoto: Codable, Hashable, Sendable {
    /// Type of the content, must be *photo*
    public var type: InputStoryContentKind

    /// The photo to post as a story. The photo must be of the size 1080x1920 and must not
    /// exceed 10 MB. The photo can't be reused and can only be uploaded as a new file, so you
    /// can pass “attach://<file_attach_name>” if the photo was uploaded using
    /// multipart/form-data under <file_attach_name>. More information on Sending Files »
    public var photo: Swift.String

    public init(
        type: InputStoryContentKind = .photo,
        photo: Swift.String
    ) {
        self.type = type
        self.photo = photo
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case photo
    }
}
