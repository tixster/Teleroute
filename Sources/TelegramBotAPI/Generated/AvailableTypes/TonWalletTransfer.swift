// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a service message about a transfer with a TON wallet.
public struct TonWalletTransfer: Codable, Hashable, Sendable {
    /// Unique identifier of the transaction; may be empty if the transfer hasn't been sent yet
    public var transactionId: Swift.String

    /// Address of the transfer peer in the TON blockchain
    public var peerAddress: Swift.String

    /// The amount of transferred cryptocurrency, in the *smallest units* of the cryptocurrency,
    /// as a decimal number; negative for outgoing transfers
    public var amount: Swift.String

    /// *Optional*. Comment added to the transfer; omitted if the comment is encrypted
    public var comment: Swift.String?

    public init(
        transactionId: Swift.String,
        peerAddress: Swift.String,
        amount: Swift.String,
        comment: Swift.String? = nil
    ) {
        self.transactionId = transactionId
        self.peerAddress = peerAddress
        self.amount = amount
        self.comment = comment
    }

    public enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case peerAddress = "peer_address"
        case amount
        case comment
    }
}
