import Foundation

/// The canonical wire format for persisting flow sessions.
///
/// A ``TelerouteFlowStorage`` backed by Redis, Postgres, or any other shared
/// store has to turn a ``TelerouteFlowSession`` into bytes. Use this rather
/// than rolling your own encoder: it pins the date strategy and carries a
/// schema version, so records written by one deployment stay readable by the
/// next.
///
/// ```swift
/// func setSession(_ session: TelerouteFlowSession, for key: TelerouteFlowKey) async {
///     let payload = try? TelerouteFlowSessionCoding.encodeToString(session)
///     await redis.set(key.storageKey, to: payload, expiring: session.timeToLive())
/// }
/// ```
public enum TelerouteFlowSessionCoding {
    /// Schema version written into every encoded record.
    public static let schemaVersion = 1

    private struct Envelope: Codable {
        let v: Int
        let session: TelerouteFlowSession
    }

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

    /// Encodes a session into its canonical JSON representation.
    public static func encode(_ session: TelerouteFlowSession) throws -> Data {
        try self.encoder.encode(Envelope(v: self.schemaVersion, session: session))
    }

    /// Encodes a session into a canonical JSON string.
    public static func encodeToString(_ session: TelerouteFlowSession) throws -> String {
        String(decoding: try self.encode(session), as: UTF8.self)
    }

    /// Decodes a session from its canonical representation.
    ///
    /// A bare session object — no envelope — decodes too, so records written
    /// by hand or by an older integration are still readable.
    public static func decode(_ data: Data) throws -> TelerouteFlowSession {
        let decoder = self.decoder
        if let envelope = try? decoder.decode(Envelope.self, from: data) {
            return envelope.session
        }
        return try decoder.decode(TelerouteFlowSession.self, from: data)
    }

    /// Decodes a session from a canonical JSON string.
    public static func decode(_ string: String) throws -> TelerouteFlowSession {
        try self.decode(Data(string.utf8))
    }
}
