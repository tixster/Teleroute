// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Contains information about the affiliate that received a commission via this transaction.
public struct AffiliateInfo: Codable, Hashable, Sendable {
    private var affiliateUserBox: _IndirectBox<User>?
    /// *Optional*. The bot or the user that received an affiliate commission if it was received
    /// by a bot or a user
    public var affiliateUser: User? {
        get { self.affiliateUserBox?.value }
        set { self.affiliateUserBox = newValue.map(_IndirectBox.init) }
    }

    private var affiliateChatBox: _IndirectBox<Chat>?
    /// *Optional*. The chat that received an affiliate commission if it was received by a chat
    public var affiliateChat: Chat? {
        get { self.affiliateChatBox?.value }
        set { self.affiliateChatBox = newValue.map(_IndirectBox.init) }
    }

    /// The number of Telegram Stars received by the affiliate for each 1000 Telegram Stars
    /// received by the bot from referred users
    public var commissionPerMille: Swift.Int64

    /// Integer amount of Telegram Stars received by the affiliate from the transaction, rounded
    /// to 0; can be negative for refunds
    public var amount: Swift.Int64

    /// *Optional*. The number of 1/1000000000 shares of Telegram Stars received by the
    /// affiliate; from -999999999 to 999999999; can be negative for refunds
    public var nanostarAmount: Swift.Int64?

    public init(
        affiliateUser: User? = nil,
        affiliateChat: Chat? = nil,
        commissionPerMille: Swift.Int64,
        amount: Swift.Int64,
        nanostarAmount: Swift.Int64? = nil
    ) {
        self.affiliateUserBox = affiliateUser.map(_IndirectBox.init)
        self.affiliateChatBox = affiliateChat.map(_IndirectBox.init)
        self.commissionPerMille = commissionPerMille
        self.amount = amount
        self.nanostarAmount = nanostarAmount
    }

    public enum CodingKeys: String, CodingKey {
        case affiliateUserBox = "affiliate_user"
        case affiliateChatBox = "affiliate_chat"
        case commissionPerMille = "commission_per_mille"
        case amount
        case nanostarAmount = "nanostar_amount"
    }
}
