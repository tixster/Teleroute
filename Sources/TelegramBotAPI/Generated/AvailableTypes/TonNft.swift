// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents an NFT in the TON blockchain.
public struct TonNft: Codable, Hashable, Sendable {
    /// Address of the NFT
    public var address: Swift.String

    /// *Optional*. Address of the collection to which the NFT belongs; omitted if unknown
    public var collectionAddress: Swift.String?

    /// Index of the NFT among all NFTs from the collection as a decimal number
    public var index: Swift.String

    /// Name of the NFT
    public var name: Swift.String

    /// Description of the NFT
    public var description: Swift.String

    /// *Optional*. Attributes of the NFT
    public var attributes: [TonNftAttribute]?

    private var giftBox: _IndirectBox<UniqueGift>?
    /// *Optional*. The unique gift corresponding to the NFT
    public var gift: UniqueGift? {
        get { self.giftBox?.value }
        set { self.giftBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        address: Swift.String,
        collectionAddress: Swift.String? = nil,
        index: Swift.String,
        name: Swift.String,
        description: Swift.String,
        attributes: [TonNftAttribute]? = nil,
        gift: UniqueGift? = nil
    ) {
        self.address = address
        self.collectionAddress = collectionAddress
        self.index = index
        self.name = name
        self.description = description
        self.attributes = attributes
        self.giftBox = gift.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case address
        case collectionAddress = "collection_address"
        case index
        case name
        case description
        case attributes
        case giftBox = "gift"
    }
}
