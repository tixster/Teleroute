// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a service message about the failed approval of a suggested post. Currently, only
/// caused by insufficient user funds at the time of approval.
public struct SuggestedPostApprovalFailed: Codable, Hashable, Sendable {
    private var suggestedPostMessageBox: _IndirectBox<Message>?
    /// *Optional*. Message containing the suggested post whose approval has failed. Note that
    /// the ``Message`` object in this field will not contain the *reply_to_message* field even
    /// if it itself is a reply.
    public var suggestedPostMessage: Message? {
        get { self.suggestedPostMessageBox?.value }
        set { self.suggestedPostMessageBox = newValue.map(_IndirectBox.init) }
    }

    /// Expected price of the post
    public var price: SuggestedPostPrice

    public init(
        suggestedPostMessage: Message? = nil,
        price: SuggestedPostPrice
    ) {
        self.suggestedPostMessageBox = suggestedPostMessage.map(_IndirectBox.init)
        self.price = price
    }

    public enum CodingKeys: String, CodingKey {
        case suggestedPostMessageBox = "suggested_post_message"
        case price
    }
}
