// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes a sticker on a TON wallet card.
public struct TonWalletCardSticker: Codable, Hashable, Sendable {
    /// Position of the sticker on the card
    public var position: AreaPosition

    private var nftBox: _IndirectBox<TonNft>
    /// The NFT shown as the sticker
    public var nft: TonNft {
        get { self.nftBox.value }
        set { self.nftBox = _IndirectBox(newValue) }
    }

    public init(
        position: AreaPosition,
        nft: TonNft
    ) {
        self.position = position
        self.nftBox = _IndirectBox(nft)
    }

    public enum CodingKeys: String, CodingKey {
        case position
        case nftBox = "nft"
    }
}
