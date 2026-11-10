// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes a clickable area on a story media.
public struct StoryArea: Codable, Hashable, Sendable {
    /// Position of the area
    public var position: AreaPosition

    private var typeBox: _IndirectBox<StoryAreaType>
    /// Type of the area
    public var type: StoryAreaType {
        get { self.typeBox.value }
        set { self.typeBox = _IndirectBox(newValue) }
    }

    public init(
        position: AreaPosition,
        type: StoryAreaType
    ) {
        self.position = position
        self.typeBox = _IndirectBox(type)
    }

    public enum CodingKeys: String, CodingKey {
        case position
        case typeBox = "type"
    }
}
