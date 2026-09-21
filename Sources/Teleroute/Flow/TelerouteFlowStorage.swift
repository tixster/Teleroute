import Foundation

/// Atomic transformation applied to a flow session by a storage backend.
public typealias TelerouteFlowSessionMutation = @Sendable (
    _ current: TelerouteFlowSession?
) throws -> TelerouteFlowSession?

/// Storage backend used by `Teleroute` flows.
public protocol TelerouteFlowStorage: Sendable {
    /// Returns the active flow session for a scope, if one exists.
    func session(for key: TelerouteFlowKey) async -> TelerouteFlowSession?

    /// Stores or replaces the active flow session for a scope.
    func setSession(_ session: TelerouteFlowSession, for key: TelerouteFlowKey) async

    /// Removes the active flow session for a scope.
    func removeSession(for key: TelerouteFlowKey) async

    /// Atomically transforms the active flow session for a scope.
    ///
    /// Storage implementations should override this method when they can perform
    /// the read-modify-write operation atomically. The default implementation is
    /// provided for source compatibility with existing custom storage backends.
    @discardableResult
    func updateSession(
        for key: TelerouteFlowKey,
        _ mutation: TelerouteFlowSessionMutation
    ) async rethrows -> TelerouteFlowSession?
}

public extension TelerouteFlowStorage {
    @discardableResult
    func updateSession(
        for key: TelerouteFlowKey,
        _ mutation: TelerouteFlowSessionMutation
    ) async rethrows -> TelerouteFlowSession? {
        let updated = try mutation(await self.session(for: key))
        if let updated {
            await self.setSession(updated, for: key)
        } else {
            await self.removeSession(for: key)
        }
        return updated
    }
}

/// Flow storage that can compact expired sessions proactively.
///
/// Conforming is optional and never affects correctness: the router checks
/// ``TelerouteFlowSession/isExpired(at:)`` whenever it reads a session, so an
/// expired session never routes. Implement this when a sweep is cheap and you
/// do not want dead sessions occupying the store — and skip it when the
/// backend expires keys natively (set the deadline from
/// ``TelerouteFlowSession/timeToLive(at:)`` on write instead).
public protocol TelerouteFlowStorageCleanup: TelerouteFlowStorage {
    /// Removes every session that has expired at the supplied instant.
    func removeExpiredSessions(at now: Date) async
}

/// Default in-memory flow storage.
public actor TelerouteInMemoryFlowStorage: TelerouteFlowStorage, TelerouteFlowStorageCleanup {
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

    @discardableResult
    public func updateSession(
        for key: TelerouteFlowKey,
        _ mutation: TelerouteFlowSessionMutation
    ) rethrows -> TelerouteFlowSession? {
        // A throwing mutation must not write, so the session stays exactly as
        // it was. Flow steps rely on this to refuse advancing a session that
        // has ended.
        let updated = try mutation(self.sessions[key])
        self.sessions[key] = updated
        return updated
    }

    public func removeExpiredSessions(at now: Date = Date()) {
        self.sessions = self.sessions.filter { $0.value.isExpired(at: now) == false }
    }
}
