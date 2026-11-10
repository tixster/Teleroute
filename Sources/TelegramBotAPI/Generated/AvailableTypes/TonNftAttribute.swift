// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents an attribute of an NFT in the TON blockchain.
public struct TonNftAttribute: Codable, Hashable, Sendable {
    /// Trait type of the attribute
    public var traitType: Swift.String

    /// Value of the attribute
    public var value: Swift.String

    public init(
        traitType: Swift.String,
        value: Swift.String
    ) {
        self.traitType = traitType
        self.value = value
    }

    public enum CodingKeys: String, CodingKey {
        case traitType = "trait_type"
        case value
    }
}
