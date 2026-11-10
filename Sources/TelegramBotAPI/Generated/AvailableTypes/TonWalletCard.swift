// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes a TON wallet card, which is shown on the profile page of a user to
/// everyone.
public struct TonWalletCard: Codable, Hashable, Sendable {
    /// Address of the wallet
    public var address: Swift.String

    /// Balance of the wallet, in the *smallest units* of the cryptocurrency, as a decimal
    /// number
    public var amount: Swift.String

    /// Stickers placed on the card
    public var stickers: [TonWalletCardSticker]

    /// *Optional*. Address of the NFT of one of the stickers, whose colors must be used for the
    /// card background; omitted if the default background must be used
    public var backgroundNftAddress: Swift.String?

    public init(
        address: Swift.String,
        amount: Swift.String,
        stickers: [TonWalletCardSticker],
        backgroundNftAddress: Swift.String? = nil
    ) {
        self.address = address
        self.amount = amount
        self.stickers = stickers
        self.backgroundNftAddress = backgroundNftAddress
    }

    public enum CodingKeys: String, CodingKey {
        case address
        case amount
        case stickers
        case backgroundNftAddress = "background_nft_address"
    }
}
