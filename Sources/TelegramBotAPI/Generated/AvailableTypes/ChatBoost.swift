// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains information about a chat boost.
public struct ChatBoost: Codable, Hashable, Sendable {
    /// Unique identifier of the boost
    public var boostId: Swift.String

    /// Point in time (Unix timestamp) when the chat was boosted
    public var addDate: Swift.Int64

    /// Point in time (Unix timestamp) when the boost will automatically expire, unless the
    /// booster's Telegram Premium subscription is prolonged
    public var expirationDate: Swift.Int64

    private var sourceBox: _IndirectBox<ChatBoostSource>
    /// Source of the added boost
    public var source: ChatBoostSource {
        get { self.sourceBox.value }
        set { self.sourceBox = _IndirectBox(newValue) }
    }

    public init(
        boostId: Swift.String,
        addDate: Swift.Int64,
        expirationDate: Swift.Int64,
        source: ChatBoostSource
    ) {
        self.boostId = boostId
        self.addDate = addDate
        self.expirationDate = expirationDate
        self.sourceBox = _IndirectBox(source)
    }

    public enum CodingKeys: String, CodingKey {
        case boostId = "boost_id"
        case addDate = "add_date"
        case expirationDate = "expiration_date"
        case sourceBox = "source"
    }
}
