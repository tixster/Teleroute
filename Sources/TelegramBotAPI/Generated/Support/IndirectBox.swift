// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Reference storage for a field that cannot be held inline.
///
/// Two unrelated problems need this. A handful of Telegram objects
/// contain themselves — a `Message` carries the `Message` it replies to
/// — which a struct cannot do directly. And a few are simply too big to
/// copy onto the stack: left inline, `Update` lays out at roughly
/// 125 KB because it holds seven `Message` fields.
///
/// Only the offending field is boxed, so the rest of the type keeps its
/// inline storage and its public API is unchanged.
public final class _IndirectBox<Value>: @unchecked Sendable {
    public let value: Value
    public init(_ value: Value) { self.value = value }
}

extension _IndirectBox: Equatable where Value: Equatable {
    public static func == (lhs: _IndirectBox, rhs: _IndirectBox) -> Bool {
        lhs.value == rhs.value
    }
}

extension _IndirectBox: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(self.value) }
}

extension _IndirectBox: Encodable where Value: Encodable {
    public func encode(to encoder: any Encoder) throws {
        try self.value.encode(to: encoder)
    }
}

extension _IndirectBox: Decodable where Value: Decodable {
    public convenience init(from decoder: any Decoder) throws {
        self.init(try Value(from: decoder))
    }
}
