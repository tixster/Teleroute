// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents one row of the high scores table for a game.
public struct GameHighScore: Codable, Hashable, Sendable {
    /// Position in high score table for the game
    public var position: Swift.Int64

    private var userBox: _IndirectBox<User>
    /// User
    public var user: User {
        get { self.userBox.value }
        set { self.userBox = _IndirectBox(newValue) }
    }

    /// Score
    public var score: Swift.Int64

    public init(
        position: Swift.Int64,
        user: User,
        score: Swift.Int64
    ) {
        self.position = position
        self.userBox = _IndirectBox(user)
        self.score = score
    }

    public enum CodingKeys: String, CodingKey {
        case position
        case userBox = "user"
        case score
    }
}
