import Foundation
import HeapModule

private let telerouteReplayProtectionClock = ContinuousClock()

/// Storage backend used to suppress duplicate command and callback handling.
public protocol TelerouteReplayProtectionStorage: Sendable {
    /// Returns `true` when this key should be handled now, and reserves it for the given TTL.
    func claim(key: String, ttl: Duration) async -> Bool
}

/// Replay protection storage that can compact expired entries proactively.
public protocol TelerouteReplayProtectionCleanupStorage: TelerouteReplayProtectionStorage {
    /// Removes expired replay-protection keys.
    func removeExpired() async
}

/// Default in-memory replay protection storage.
public actor TelerouteInMemoryReplayProtectionStorage: TelerouteReplayProtectionCleanupStorage {
    private var expirations: [String: ContinuousClock.Instant] = [:]
    private var expirationHeap = Heap<TelerouteReplayExpiration>()
    private var nextSequence = 0

    public init() {}

    public func claim(key: String, ttl: Duration) -> Bool {
        let now = telerouteReplayProtectionClock.now
        self.removeExpired(now: now)

        if let expiration = self.expirations[key], expiration > now {
            return false
        }

        let expiration = now.advanced(by: ttl)
        self.expirations[key] = expiration
        self.expirationHeap.insert(
            .init(
                key: key,
                expiration: expiration,
                sequence: self.nextSequence
            )
        )
        self.nextSequence += 1
        return true
    }

    public func removeExpired() {
        self.removeExpired(now: telerouteReplayProtectionClock.now)
    }

    private func removeExpired(now: ContinuousClock.Instant) {
        while let next = self.expirationHeap.min, next.expiration <= now {
            _ = self.expirationHeap.popMin()
            if self.expirations[next.key] == next.expiration {
                self.expirations[next.key] = nil
            }
        }
    }

    var storedKeyCount: Int {
        self.expirations.count
    }
}

private struct TelerouteReplayExpiration: Comparable, Sendable {
    let key: String
    let expiration: ContinuousClock.Instant
    let sequence: Int

    static func < (
        lhs: TelerouteReplayExpiration,
        rhs: TelerouteReplayExpiration
    ) -> Bool {
        if lhs.expiration != rhs.expiration {
            return lhs.expiration < rhs.expiration
        }
        return lhs.sequence < rhs.sequence
    }
}
