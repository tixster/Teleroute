// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object represents a chat background.
public struct ChatBackground: Codable, Hashable, Sendable {
    private var typeBox: _IndirectBox<BackgroundType>
    /// Type of the background
    public var type: BackgroundType {
        get { self.typeBox.value }
        set { self.typeBox = _IndirectBox(newValue) }
    }

    public init(
        type: BackgroundType
    ) {
        self.typeBox = _IndirectBox(type)
    }

    public enum CodingKeys: String, CodingKey {
        case typeBox = "type"
    }
}
