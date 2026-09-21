// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a service message about the approval of a suggested post.
public struct SuggestedPostApproved: Codable, Hashable, Sendable {
    private var suggestedPostMessageBox: _IndirectBox<Message>?
    /// *Optional*. Message containing the suggested post. Note that the ``Message`` object in
    /// this field will not contain the *reply_to_message* field even if it itself is a reply.
    public var suggestedPostMessage: Message? {
        get { self.suggestedPostMessageBox?.value }
        set { self.suggestedPostMessageBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Amount paid for the post
    public var price: SuggestedPostPrice?

    /// Date when the post will be published
    public var sendDate: Swift.Int64

    public init(
        suggestedPostMessage: Message? = nil,
        price: SuggestedPostPrice? = nil,
        sendDate: Swift.Int64
    ) {
        self.suggestedPostMessageBox = suggestedPostMessage.map(_IndirectBox.init)
        self.price = price
        self.sendDate = sendDate
    }

    public enum CodingKeys: String, CodingKey {
        case suggestedPostMessageBox = "suggested_post_message"
        case price
        case sendDate = "send_date"
    }
}
