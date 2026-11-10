// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes a TON wallet of the user, which is used in a query from a widget.
public struct WidgetQueryWallet: Codable, Hashable, Sendable {
    /// Address of the wallet
    public var address: Swift.String

    /// Balance of the wallet, in the *smallest units* of the cryptocurrency, as a decimal
    /// number
    public var amount: Swift.String

    /// *Optional*. Hex-encoded public key of the wallet; omitted if unknown
    public var publicKey: Swift.String?

    /// *Optional*. Base64-encoded serialized StateInit of the wallet contract; omitted if and
    /// only if *public_key* is omitted
    public var stateInit: Swift.String?

    public init(
        address: Swift.String,
        amount: Swift.String,
        publicKey: Swift.String? = nil,
        stateInit: Swift.String? = nil
    ) {
        self.address = address
        self.amount = amount
        self.publicKey = publicKey
        self.stateInit = stateInit
    }

    public enum CodingKeys: String, CodingKey {
        case address
        case amount
        case publicKey = "public_key"
        case stateInit = "state_init"
    }
}
