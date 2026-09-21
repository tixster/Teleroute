// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a transaction with a user.
public struct TransactionPartnerUser: Codable, Hashable, Sendable {
    /// Type of the transaction partner, always “user”
    public var type: TransactionPartnerKind

    /// Type of the transaction, currently one of “invoice_payment” for payments via invoices,
    /// “paid_media_payment” for payments for paid media, “gift_purchase” for gifts sent by the
    /// bot, “premium_purchase” for Telegram Premium subscriptions gifted by the bot,
    /// “business_account_transfer” for direct transfers from managed business accounts
    public var transactionType: TransactionPartnerUserTransactionType

    private var userBox: _IndirectBox<User>
    /// Information about the user
    public var user: User {
        get { self.userBox.value }
        set { self.userBox = _IndirectBox(newValue) }
    }

    private var affiliateBox: _IndirectBox<AffiliateInfo>?
    /// *Optional*. Information about the affiliate that received a commission via this
    /// transaction. Can be available only for “invoice_payment” and “paid_media_payment”
    /// transactions.
    public var affiliate: AffiliateInfo? {
        get { self.affiliateBox?.value }
        set { self.affiliateBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Bot-specified invoice payload. Can be available only for “invoice_payment”
    /// transactions.
    public var invoicePayload: Swift.String?

    /// *Optional*. The duration of the paid subscription. Can be available only for
    /// “invoice_payment” transactions.
    public var subscriptionPeriod: Swift.Int64?

    /// *Optional*. Information about the paid media bought by the user; for
    /// “paid_media_payment” transactions only
    public var paidMedia: [PaidMedia]?

    /// *Optional*. Bot-specified paid media payload. Can be available only for
    /// “paid_media_payment” transactions.
    public var paidMediaPayload: Swift.String?

    private var giftBox: _IndirectBox<Gift>?
    /// *Optional*. The gift sent to the user by the bot; for “gift_purchase” transactions only
    public var gift: Gift? {
        get { self.giftBox?.value }
        set { self.giftBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Number of months the gifted Telegram Premium subscription will be active
    /// for; for “premium_purchase” transactions only
    public var premiumSubscriptionDuration: Swift.Int64?

    public init(
        type: TransactionPartnerKind = .user,
        transactionType: TransactionPartnerUserTransactionType,
        user: User,
        affiliate: AffiliateInfo? = nil,
        invoicePayload: Swift.String? = nil,
        subscriptionPeriod: Swift.Int64? = nil,
        paidMedia: [PaidMedia]? = nil,
        paidMediaPayload: Swift.String? = nil,
        gift: Gift? = nil,
        premiumSubscriptionDuration: Swift.Int64? = nil
    ) {
        self.type = type
        self.transactionType = transactionType
        self.userBox = _IndirectBox(user)
        self.affiliateBox = affiliate.map(_IndirectBox.init)
        self.invoicePayload = invoicePayload
        self.subscriptionPeriod = subscriptionPeriod
        self.paidMedia = paidMedia
        self.paidMediaPayload = paidMediaPayload
        self.giftBox = gift.map(_IndirectBox.init)
        self.premiumSubscriptionDuration = premiumSubscriptionDuration
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case transactionType = "transaction_type"
        case userBox = "user"
        case affiliateBox = "affiliate"
        case invoicePayload = "invoice_payload"
        case subscriptionPeriod = "subscription_period"
        case paidMedia = "paid_media"
        case paidMediaPayload = "paid_media_payload"
        case giftBox = "gift"
        case premiumSubscriptionDuration = "premium_subscription_duration"
    }
}
