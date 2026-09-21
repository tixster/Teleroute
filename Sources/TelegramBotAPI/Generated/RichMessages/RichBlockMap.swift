// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A block with a map, corresponding to the custom HTML tag `<tg-map>`.
public struct RichBlockMap: Codable, Hashable, Sendable {
    /// Type of the block, always “map”
    public var type: RichBlockKind

    /// Location of the center of the map
    public var location: Location

    /// Map zoom level
    public var zoom: Swift.Int64

    /// Expected width of the map
    public var width: Swift.Int64

    /// Expected height of the map
    public var height: Swift.Int64

    /// *Optional*. Caption of the block
    public var caption: RichBlockCaption?

    public init(
        type: RichBlockKind = .map,
        location: Location,
        zoom: Swift.Int64,
        width: Swift.Int64,
        height: Swift.Int64,
        caption: RichBlockCaption? = nil
    ) {
        self.type = type
        self.location = location
        self.zoom = zoom
        self.width = width
        self.height = height
        self.caption = caption
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case location
        case zoom
        case width
        case height
        case caption
    }
}
