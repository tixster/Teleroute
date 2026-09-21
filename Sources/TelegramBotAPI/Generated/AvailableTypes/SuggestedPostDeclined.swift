// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a service message about the rejection of a suggested post.
public struct SuggestedPostDeclined: Codable, Hashable, Sendable {
    private var suggestedPostMessageBox: _IndirectBox<Message>?
    /// *Optional*. Message containing the suggested post. Note that the ``Message`` object in
    /// this field will not contain the *reply_to_message* field even if it itself is a reply.
    public var suggestedPostMessage: Message? {
        get { self.suggestedPostMessageBox?.value }
        set { self.suggestedPostMessageBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Comment with which the post was declined
    public var comment: Swift.String?

    public init(
        suggestedPostMessage: Message? = nil,
        comment: Swift.String? = nil
    ) {
        self.suggestedPostMessageBox = suggestedPostMessage.map(_IndirectBox.init)
        self.comment = comment
    }

    public enum CodingKeys: String, CodingKey {
        case suggestedPostMessageBox = "suggested_post_message"
        case comment
    }
}
