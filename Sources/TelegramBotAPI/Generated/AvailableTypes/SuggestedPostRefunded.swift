// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a service message about a payment refund for a suggested post.
public struct SuggestedPostRefunded: Codable, Hashable, Sendable {
    private var suggestedPostMessageBox: _IndirectBox<Message>?
    /// *Optional*. Message containing the suggested post. Note that the ``Message`` object in
    /// this field will not contain the *reply_to_message* field even if it itself is a reply.
    public var suggestedPostMessage: Message? {
        get { self.suggestedPostMessageBox?.value }
        set { self.suggestedPostMessageBox = newValue.map(_IndirectBox.init) }
    }

    /// Reason for the refund. Currently, one of “post_deleted” if the post was deleted within
    /// 24 hours of being posted or removed from scheduled messages without being posted, or
    /// “payment_refunded” if the payer refunded their payment.
    public var reason: SuggestedPostRefundedReason

    public init(
        suggestedPostMessage: Message? = nil,
        reason: SuggestedPostRefundedReason
    ) {
        self.suggestedPostMessageBox = suggestedPostMessage.map(_IndirectBox.init)
        self.reason = reason
    }

    public enum CodingKeys: String, CodingKey {
        case suggestedPostMessageBox = "suggested_post_message"
        case reason
    }
}
