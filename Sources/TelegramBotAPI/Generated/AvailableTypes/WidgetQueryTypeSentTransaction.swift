// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The query notifies the bot about a transaction sent from a TON wallet of the user who sent
/// the query.
public struct WidgetQueryTypeSentTransaction: Codable, Hashable, Sendable {
    /// Type of the query, always “sent_transaction”
    public var type: WidgetQueryTypeKind

    /// The wallet from which the transaction was sent
    public var wallet: WidgetQueryWallet

    /// Value of *msg_hash* of the transaction
    public var msgHash: Swift.String

    public init(
        type: WidgetQueryTypeKind = .sentTransaction,
        wallet: WidgetQueryWallet,
        msgHash: Swift.String
    ) {
        self.type = type
        self.wallet = wallet
        self.msgHash = msgHash
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case wallet
        case msgHash = "msg_hash"
    }
}
