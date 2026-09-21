// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes the affiliate program that issued the affiliate commission received via this
/// transaction.
public struct TransactionPartnerAffiliateProgram: Codable, Hashable, Sendable {
    /// Type of the transaction partner, always “affiliate_program”
    public var type: TransactionPartnerKind

    private var sponsorUserBox: _IndirectBox<User>?
    /// *Optional*. Information about the bot that sponsored the affiliate program
    public var sponsorUser: User? {
        get { self.sponsorUserBox?.value }
        set { self.sponsorUserBox = newValue.map(_IndirectBox.init) }
    }

    /// The number of Telegram Stars received by the bot for each 1000 Telegram Stars received
    /// by the affiliate program sponsor from referred users
    public var commissionPerMille: Swift.Int64

    public init(
        type: TransactionPartnerKind = .affiliateProgram,
        sponsorUser: User? = nil,
        commissionPerMille: Swift.Int64
    ) {
        self.type = type
        self.sponsorUserBox = sponsorUser.map(_IndirectBox.init)
        self.commissionPerMille = commissionPerMille
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case sponsorUserBox = "sponsor_user"
        case commissionPerMille = "commission_per_mille"
    }
}
