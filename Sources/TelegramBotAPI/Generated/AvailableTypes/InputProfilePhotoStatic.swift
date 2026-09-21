// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A static profile photo in the .JPG format.
public struct InputProfilePhotoStatic: Codable, Hashable, Sendable {
    /// Type of the profile photo, must be *static*
    public var type: InputProfilePhotoKind

    /// The static profile photo. Profile photos can't be reused and can only be uploaded as a
    /// new file, so you can pass “attach://<file_attach_name>” if the photo was uploaded using
    /// multipart/form-data under <file_attach_name>. More information on Sending Files »
    public var photo: Swift.String

    public init(
        type: InputProfilePhotoKind = .static,
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
