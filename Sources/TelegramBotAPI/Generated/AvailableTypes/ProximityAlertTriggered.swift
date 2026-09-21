// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents the content of a service message, sent whenever a user in the chat
/// triggers a proximity alert set by another user.
public struct ProximityAlertTriggered: Codable, Hashable, Sendable {
    private var travelerBox: _IndirectBox<User>
    /// User that triggered the alert
    public var traveler: User {
        get { self.travelerBox.value }
        set { self.travelerBox = _IndirectBox(newValue) }
    }

    private var watcherBox: _IndirectBox<User>
    /// User that set the alert
    public var watcher: User {
        get { self.watcherBox.value }
        set { self.watcherBox = _IndirectBox(newValue) }
    }

    /// The distance between the users
    public var distance: Swift.Int64

    public init(
        traveler: User,
        watcher: User,
        distance: Swift.Int64
    ) {
        self.travelerBox = _IndirectBox(traveler)
        self.watcherBox = _IndirectBox(watcher)
        self.distance = distance
    }

    public enum CodingKeys: String, CodingKey {
        case travelerBox = "traveler"
        case watcherBox = "watcher"
        case distance
    }
}
