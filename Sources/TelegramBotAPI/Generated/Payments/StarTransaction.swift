// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a Telegram Star transaction. Note that if the buyer initiates a chargeback with
/// the payment provider from whom they acquired Stars (e.g., Apple, Google) following this
/// transaction, the refunded Stars will be deducted from the bot's balance. This is outside of
/// Telegram's control.
public struct StarTransaction: Codable, Hashable, Sendable {
    /// Unique identifier of the transaction. Coincides with the identifier of the original
    /// transaction for refund transactions. Coincides with
    /// *SuccessfulPayment.telegram_payment_charge_id* for successful incoming payments from
    /// users.
    public var id: Swift.String

    /// Integer amount of Telegram Stars transferred by the transaction
    public var amount: Swift.Int64

    /// *Optional*. The number of 1/1000000000 shares of Telegram Stars transferred by the
    /// transaction; from 0 to 999999999
    public var nanostarAmount: Swift.Int64?

    /// Date the transaction was created in Unix time
    public var date: Swift.Int64

    private var sourceBox: _IndirectBox<TransactionPartner>?
    /// *Optional*. Source of an incoming transaction (e.g., a user purchasing goods or
    /// services, Fragment refunding a failed withdrawal). Only for incoming transactions.
    public var source: TransactionPartner? {
        get { self.sourceBox?.value }
        set { self.sourceBox = newValue.map(_IndirectBox.init) }
    }

    private var receiverBox: _IndirectBox<TransactionPartner>?
    /// *Optional*. Receiver of an outgoing transaction (e.g., a user for a purchase refund,
    /// Fragment for a withdrawal). Only for outgoing transactions.
    public var receiver: TransactionPartner? {
        get { self.receiverBox?.value }
        set { self.receiverBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        id: Swift.String,
        amount: Swift.Int64,
        nanostarAmount: Swift.Int64? = nil,
        date: Swift.Int64,
        source: TransactionPartner? = nil,
        receiver: TransactionPartner? = nil
    ) {
        self.id = id
        self.amount = amount
        self.nanostarAmount = nanostarAmount
        self.date = date
        self.sourceBox = source.map(_IndirectBox.init)
        self.receiverBox = receiver.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case amount
        case nanostarAmount = "nanostar_amount"
        case date
        case sourceBox = "source"
        case receiverBox = "receiver"
    }
}
