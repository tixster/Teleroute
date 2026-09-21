// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A block with a map, corresponding to the custom HTML tag `<tg-map>`. The map's width and
/// height must not exceed 10000 in total. The width and height ratio must be at most 20.
public struct InputRichBlockMap: Codable, Hashable, Sendable {
    /// Type of the block, always “map”
    public var type: RichBlockKind

    /// Location of the center of the map
    public var location: Location

    /// *Optional*. Map zoom level; 0-24
    public var zoom: Swift.Int64?

    /// *Optional*. Map width; 0-10000
    public var width: Swift.Int64?

    /// *Optional*. Map height; 0-10000
    public var height: Swift.Int64?

    /// *Optional*. Caption of the block
    public var caption: RichBlockCaption?

    public init(
        type: RichBlockKind = .map,
        location: Location,
        zoom: Swift.Int64? = nil,
        width: Swift.Int64? = nil,
        height: Swift.Int64? = nil,
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
