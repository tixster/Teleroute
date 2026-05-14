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

    /// Returns all stored values as a dictionary.
    public var dictionary: [String: String] {
        self.storage
    }

    /// Returns the value for a stored key, if it exists.
    public subscript(_ name: String) -> String? {
        self.get(name)
    }

    func merging(_ values: [String: String]) -> TelerouteFlowValues {
        .init(self.storage.merging(values) { _, new in new })
    }
}

/// Unique flow session scope derived from the current Telegram chat and user.
public struct TelerouteFlowKey: Hashable, Sendable {
    public let chatId: Int64
    public let userId: Int64?

    /// Creates a flow key for a chat and an optional user.
    public init(chatId: Int64, userId: Int64?) {
        self.chatId = chatId
        self.userId = userId
    }
}

/// Snapshot of the currently active flow session.
public struct TelerouteFlowSession: Sendable {
    /// Flow identifier.
    public let id: String
    /// Raw step identifier inside the flow.
    public let step: String
    /// Flow values accumulated so far.
    public let values: TelerouteFlowValues

    /// Creates a flow session snapshot.
    public init(id: String, step: String, values: TelerouteFlowValues) {
        self.id = id
        self.step = step
        self.values = values
    }
}
