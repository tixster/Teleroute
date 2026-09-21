import Foundation

/// Pins the JSON representation of ``TelerouteFlow/FlowState``, the way
/// ``TelerouteFlowSessionCoding`` does for the session record.
///
/// Typed state is stored as a JSON string inside the ordinary flow values, so
/// this decides only how that one string is written — the session's own wire
/// format is unchanged.
public enum TelerouteFlowStateCoding {
    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    public static func encodeToString(_ state: some Encodable) throws -> String {
        String(decoding: try self.encoder.encode(state), as: UTF8.self)
    }

    public static func decode<State: Decodable>(
        _ type: State.Type,
        from string: String
    ) throws -> State {
        try self.decoder.decode(State.self, from: Data(string.utf8))
    }
}

/// A type that can be created empty.
///
/// Conform your ``TelerouteFlow/FlowState`` to it to use
/// ``TelerouteFlowContext/mutateState(_:)``, which needs a starting value when
/// the session carries no state yet. A struct whose properties all have
/// defaults gets `init()` for free — just add the conformance.
public protocol TelerouteDefaultInitializable {
    init()
}

extension TelerouteEmptyFlowState: TelerouteDefaultInitializable {}
