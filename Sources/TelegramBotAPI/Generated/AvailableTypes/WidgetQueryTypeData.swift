// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The query contains data for the bot.
public struct WidgetQueryTypeData: Codable, Hashable, Sendable {
    /// Type of the query, always “data”
    public var type: WidgetQueryTypeKind

    /// *Optional*. TON wallet card of the user who sent the query, if it was sent to the bot
    /// along with the query
    public var walletCard: TonWalletCard?

    public init(
        type: WidgetQueryTypeKind = .data,
        walletCard: TonWalletCard? = nil
    ) {
        self.type = type
        self.walletCard = walletCard
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case walletCard = "wallet_card"
    }
}
