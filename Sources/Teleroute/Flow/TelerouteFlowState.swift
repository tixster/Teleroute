import Foundation

/// Values stored inside an active flow session.
public struct TelerouteFlowValues: Sendable {
    private let storage: [String: String]

    /// Creates a flow values container from a dictionary.
    public init(_ storage: [String: String] = [:]) {
        self.storage = storage
    }

    /// Returns `true` when the flow session does not store any values.
    public var isEmpty: Bool {
        self.storage.isEmpty
    }

    /// Returns the value for a stored key, if it exists.
    public func get(_ name: String) -> String? {
        self.storage[name]
    }

    /// Returns the value for a stored key or throws when it is missing.
    public func require(_ name: String) throws -> String {
        guard let value = self.get(name) else {
            throw TelerouteError.missingParameter(name)
        }
        return value
    }

    /// Returns the value decoded into a `LosslessStringConvertible` type, or
    /// `nil` when it is missing or malformed.
    public func get<Value: LosslessStringConvertible>(
        _ name: String,
        as type: Value.Type
    ) -> Value? {
        self.get(name).flatMap(Value.init)
    }

    /// Returns the value decoded into a `LosslessStringConvertible` type or
    /// throws when it is missing or malformed.
    public func require<Value: LosslessStringConvertible>(
        _ name: String,
        as type: Value.Type
    ) throws -> Value {
        let raw = try self.require(name)
        guard let value = Value(raw) else {
            throw TelerouteError.invalidParameter(name: name, value: raw)
        }
        return value
    }

    /// Returns a copy without the supplied keys.
    public func removing(_ names: String...) -> TelerouteFlowValues {
        var storage = self.storage
        for name in names {
            storage.removeValue(forKey: name)
        }
        return .init(storage)
    }

    /// Every stored key.
    public var keys: Dictionary<String, String>.Keys {
        self.storage.keys
    }

    /// The number of stored values.
    public var count: Int {
        self.storage.count
    }

    /// Returns all stored values as a dictionary.
    public var dictionary: [String: String] {
        self.storage
    }

    /// Returns the value for a stored key, if it exists.
    public subscript(_ name: String) -> String? {
        self.get(name)
    }

    /// Returns a copy with the supplied values merged in; on a key collision
    /// the new value wins.
    public func merging(_ values: [String: String]) -> TelerouteFlowValues {
        .init(self.storage.merging(values) { _, new in new })
    }
}

extension TelerouteFlowValues: Equatable, Hashable {}

/// Encodes as a plain JSON object (`{"name":"Alice"}`) rather than wrapping the
/// storage in another layer, so a persisted session stays readable.
extension TelerouteFlowValues: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(try container.decode([String: String].self))
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.dictionary)
    }
}

extension TelerouteFlowValues: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        self.init(Dictionary(elements) { _, new in new })
    }
}

extension TelerouteFlowValues: CustomStringConvertible {
    public var description: String {
        "\(self.dictionary)"
    }
}

/// Unique flow session scope derived from the current Telegram chat and user.
public struct TelerouteFlowKey: Hashable, Sendable, Codable {
    public let chatId: Int64
    public let userId: Int64?

    /// Creates a flow key for a chat and an optional user.
    public init(chatId: Int64, userId: Int64?) {
        self.chatId = chatId
        self.userId = userId
    }

    private enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case userId = "user_id"
    }

    /// A canonical, reversible string form for key-value backends such as
    /// Redis: `"<chatId>:<userId>"`, with `-` standing in for a missing user.
    ///
    /// Storage implementations should use this rather than inventing a format,
    /// so sessions stay readable across deployments.
    public var storageKey: String {
        self.userId.map { "\(self.chatId):\($0)" } ?? "\(self.chatId):-"
    }

    /// Reconstructs a key from ``storageKey``.
    public init?(storageKey: String) {
        let parts = storageKey.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2, let chatId = Int64(parts[0]) else { return nil }
        self.chatId = chatId
        self.userId = parts[1] == "-" ? nil : Int64(parts[1])
        if parts[1] != "-" && self.userId == nil { return nil }
    }
}

/// Snapshot of the currently active flow session.
public struct TelerouteFlowSession: Sendable, Equatable, Codable {
    /// Flow identifier.
    public let id: String
    /// Raw step identifier inside the flow.
    public let step: String
    /// Flow values accumulated so far.
    public let values: TelerouteFlowValues
    /// When the session was first started.
    public let createdAt: Date
    /// When the session last advanced — started, transitioned, updated, or
    /// restarted. Sliding expiry is measured from here.
    public let updatedAt: Date
    /// When the session stops being usable, or `nil` when it never expires on
    /// its own.
    public let expiresAt: Date?

    /// Creates a flow session snapshot that never expires on its own.
    public init(id: String, step: String, values: TelerouteFlowValues) {
        self.init(
            id: id,
            step: step,
            values: values,
            createdAt: Date(),
            updatedAt: Date(),
            expiresAt: nil
        )
    }

    /// Creates a flow session snapshot with explicit timestamps, for storage
    /// backends rehydrating a persisted session.
    public init(
        id: String,
        step: String,
        values: TelerouteFlowValues,
        createdAt: Date,
        updatedAt: Date,
        expiresAt: Date?
    ) {
        self.id = id
        self.step = step
        self.values = values
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.expiresAt = expiresAt
    }

    /// Whether the session has expired at the supplied instant.
    public func isExpired(at now: Date = Date()) -> Bool {
        guard let expiresAt = self.expiresAt else { return false }
        return expiresAt <= now
    }

    /// How long the session has left, for backends with native key expiry
    /// (Redis `PEXPIRE`). `nil` when the session does not expire on its own.
    public func timeToLive(at now: Date = Date()) -> Duration? {
        guard let expiresAt = self.expiresAt else { return nil }
        let seconds = expiresAt.timeIntervalSince(now)
        return seconds <= 0 ? .zero : .seconds(seconds)
    }

    /// Returns a copy advanced to a new step and/or values, refreshing
    /// ``updatedAt`` and the sliding expiry.
    public func advanced(
        step: String? = nil,
        values: TelerouteFlowValues? = nil,
        ttl: Duration?,
        now: Date = Date()
    ) -> TelerouteFlowSession {
        .init(
            id: self.id,
            step: step ?? self.step,
            values: values ?? self.values,
            createdAt: self.createdAt,
            updatedAt: now,
            expiresAt: ttl.map { now.addingTimeInterval(TimeInterval($0.components.seconds)) }
        )
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case step
        case values
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case expiresAt = "expires_at"
    }

    /// Decodes a session, tolerating records written before timestamps existed
    /// so an existing store keeps working after an upgrade.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.step = try container.decode(String.self, forKey: .step)
        self.values = try container.decodeIfPresent(TelerouteFlowValues.self, forKey: .values) ?? .init()
        let now = Date()
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? now
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? now
        self.expiresAt = try container.decodeIfPresent(Date.self, forKey: .expiresAt)
    }
}
