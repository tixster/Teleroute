// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// The query contains data signed by a TON wallet of the user who sent the query. The data is
/// signed for the domain `bot<bot_id>`, where `<bot_id>` is the identifier of the bot.
public struct WidgetQueryTypeSignData: Codable, Hashable, Sendable {
    /// Type of the query, always “sign_data”
    public var type: WidgetQueryTypeKind

    /// The wallet that signed the data
    public var wallet: WidgetQueryWallet

    /// JSON-serialized signed data
    public var signData: Swift.String

    public init(
        type: WidgetQueryTypeKind = .signData,
        wallet: WidgetQueryWallet,
        signData: Swift.String
    ) {
        self.type = type
        self.wallet = wallet
        self.signData = signData
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case wallet
        case signData = "sign_data"
    }
}
