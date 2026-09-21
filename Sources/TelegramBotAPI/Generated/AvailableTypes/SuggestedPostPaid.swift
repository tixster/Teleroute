// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a service message about a successful payment for a suggested post.
public struct SuggestedPostPaid: Codable, Hashable, Sendable {
    private var suggestedPostMessageBox: _IndirectBox<Message>?
    /// *Optional*. Message containing the suggested post. Note that the ``Message`` object in
    /// this field will not contain the *reply_to_message* field even if it itself is a reply.
    public var suggestedPostMessage: Message? {
        get { self.suggestedPostMessageBox?.value }
        set { self.suggestedPostMessageBox = newValue.map(_IndirectBox.init) }
    }

    /// Currency in which the payment was made. Currently, one of “XTR” for Telegram Stars or
    /// “TON” for TON grams.
    public var currency: SuggestedPostPaidCurrency

    /// *Optional*. The amount of the currency that was received by the channel in nanograms;
    /// for payments in TON grams only
    public var amount: Swift.Int64?

    /// *Optional*. The amount of Telegram Stars that was received by the channel; for payments
    /// in Telegram Stars only
    public var starAmount: StarAmount?

    public init(
        suggestedPostMessage: Message? = nil,
        currency: SuggestedPostPaidCurrency,
        amount: Swift.Int64? = nil,
        starAmount: StarAmount? = nil
    ) {
        self.suggestedPostMessageBox = suggestedPostMessage.map(_IndirectBox.init)
        self.currency = currency
        self.amount = amount
        self.starAmount = starAmount
    }

    public enum CodingKeys: String, CodingKey {
        case suggestedPostMessageBox = "suggested_post_message"
        case currency
        case amount
        case starAmount = "star_amount"
    }
}
