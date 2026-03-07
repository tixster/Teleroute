import Foundation

private let telerouteReplayProtectionClock = ContinuousClock()

/// Storage backend used to suppress duplicate command and callback handling.
public protocol TelerouteReplayProtectionStorage: Sendable {
    /// Returns `true` when this key should be handled now, and reserves it for the given TTL.
    func claim(key: String, ttl: Duration) async -> Bool
}

/// Default in-memory replay protection storage.
public actor TelerouteInMemoryReplayProtectionStorage: TelerouteReplayProtectionStorage {
    private var expirations: [String: ContinuousClock.Instant] = [:]

    public init() {}

    public func claim(key: String, ttl: Duration) -> Bool {
        let now = telerouteReplayProtectionClock.now
        self.expirations = self.expirations.filter { $0.value > now }

        if let expiration = self.expirations[key], expiration > now {
            return false
        }

        self.expirations[key] = now.advanced(by: ttl)
        return true
    }
}
