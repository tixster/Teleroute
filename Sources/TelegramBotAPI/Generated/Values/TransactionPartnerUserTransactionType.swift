// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Type of the transaction, currently one of “invoice_payment” for payments via invoices,
/// “paid_media_payment” for payments for paid media, “gift_purchase” for gifts sent by the bot,
/// “premium_purchase” for Telegram Premium subscriptions gifted by the bot,
/// “business_account_transfer” for direct transfers from managed business accounts
public enum TransactionPartnerUserTransactionType: RawRepresentable, Codable, Hashable, Sendable {
    case invoicePayment
    case paidMediaPayment
    case giftPurchase
    case premiumPurchase
    case businessAccountTransfer
    /// A value Telegram introduced after these sources were generated.
    case unknown(Swift.String)

    public var rawValue: Swift.String {
        switch self {
        case .invoicePayment: "invoice_payment"
        case .paidMediaPayment: "paid_media_payment"
        case .giftPurchase: "gift_purchase"
        case .premiumPurchase: "premium_purchase"
        case .businessAccountTransfer: "business_account_transfer"
        case let .unknown(value): value
        }
    }

    public init(rawValue: Swift.String) {
        switch rawValue {
        case "invoice_payment": self = .invoicePayment
        case "paid_media_payment": self = .paidMediaPayment
        case "gift_purchase": self = .giftPurchase
        case "premium_purchase": self = .premiumPurchase
        case "business_account_transfer": self = .businessAccountTransfer
        default: self = .unknown(rawValue)
        }
    }

    public init(from decoder: any Decoder) throws {
        self.init(rawValue: try decoder.singleValueContainer().decode(Swift.String.self))
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }

    /// Every value documented at the time these sources were generated.
    public static let documentedCases: [TransactionPartnerUserTransactionType] = [
        .invoicePayment,
        .paidMediaPayment,
        .giftPurchase,
        .premiumPurchase,
        .businessAccountTransfer,
    ]
}
