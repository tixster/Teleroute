// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains information about changes to a user payment subscription toward the
/// current bot.
public struct BotSubscriptionUpdated: Codable, Hashable, Sendable {
    private var userBox: _IndirectBox<User>
    /// User who subscribed for payments toward the bot
    public var user: User {
        get { self.userBox.value }
        set { self.userBox = _IndirectBox(newValue) }
    }

    /// Bot-specified invoice payload
    public var invoicePayload: Swift.String

    /// The new state of the subscription. Currently, it can be one of “canceled” if the user
    /// canceled the subscription, “active” if the user re-enabled a previously canceled
    /// subscription, or “failed” if payment for the subscription failed.
    public var state: BotSubscriptionUpdatedState

    public init(
        user: User,
        invoicePayload: Swift.String,
        state: BotSubscriptionUpdatedState
    ) {
        self.userBox = _IndirectBox(user)
        self.invoicePayload = invoicePayload
        self.state = state
    }

    public enum CodingKeys: String, CodingKey {
        case userBox = "user"
        case invoicePayload = "invoice_payload"
        case state
    }
}
