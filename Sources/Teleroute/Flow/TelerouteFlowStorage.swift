import Foundation

/// Storage backend used by `Teleroute` flows.
public protocol TelerouteFlowStorage: Sendable {
    /// Returns the active flow session for a scope, if one exists.
    func session(for key: TelerouteFlowKey) async -> TelerouteFlowSession?

    /// Stores or replaces the active flow session for a scope.
    func setSession(_ session: TelerouteFlowSession, for key: TelerouteFlowKey) async

    /// Removes the active flow session for a scope.
    func removeSession(for key: TelerouteFlowKey) async
}

/// Default in-memory flow storage.
public actor TelerouteInMemoryFlowStorage: TelerouteFlowStorage {
    private var sessions: [TelerouteFlowKey: TelerouteFlowSession] = [:]

    public init() {}

    public func session(for key: TelerouteFlowKey) -> TelerouteFlowSession? {
        self.sessions[key]
    }

    public func setSession(_ session: TelerouteFlowSession, for key: TelerouteFlowKey) {
        self.sessions[key] = session
    }

    public func removeSession(for key: TelerouteFlowKey) {
        self.sessions.removeValue(forKey: key)
    }
}
