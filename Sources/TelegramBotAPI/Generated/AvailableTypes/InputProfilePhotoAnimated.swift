// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// An animated profile photo in the MPEG4 format.
public struct InputProfilePhotoAnimated: Codable, Hashable, Sendable {
    /// Type of the profile photo, must be *animated*
    public var type: InputProfilePhotoKind

    /// The animated profile photo. Profile photos can't be reused and can only be uploaded as a
    /// new file, so you can pass “attach://<file_attach_name>” if the photo was uploaded using
    /// multipart/form-data under <file_attach_name>. More information on Sending Files »
    public var animation: Swift.String

    /// *Optional*. Timestamp in seconds of the frame that will be used as the static profile
    /// photo. Defaults to 0.0.
    public var mainFrameTimestamp: Swift.Double?

    public init(
        type: InputProfilePhotoKind = .animated,
        animation: Swift.String,
        mainFrameTimestamp: Swift.Double? = nil
    ) {
        self.type = type
        self.animation = animation
        self.mainFrameTimestamp = mainFrameTimestamp
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case animation
        case mainFrameTimestamp = "main_frame_timestamp"
    }
}
