import Foundation
import Synchronization

/// Buffering used independently by each ``Teleroute/eventStream(buffering:)`` subscriber.
public enum TelerouteEventBufferingPolicy: Equatable, Sendable {
    /// Retains every event until the subscriber consumes it.
    case unbounded
    /// Retains only the newest `limit` events.
    case newest(Int)
    /// Retains only the oldest `limit` events.
    case oldest(Int)

    fileprivate var streamPolicy: AsyncStream<TelerouteEvent>.Continuation.BufferingPolicy {
        switch self {
        case .unbounded:
            .unbounded
        case let .newest(limit):
            .bufferingNewest(max(0, limit))
        case let .oldest(limit):
            .bufferingOldest(max(0, limit))
        }
    }
}

/// Router lifecycle event emitted while an update moves through `Teleroute`.
public struct TelerouteEvent: Equatable, Sendable {
    public enum Kind: Equatable, Sendable {
        case received
        case skippedDuplicate
        case handled
        case unmatched
        case failed
    }

    public enum RouteKind: Equatable, Sendable {
        case command
        case callback
        case flow
        case message
        case unknown
    }

    /// Event phase.
    public let kind: Kind
    /// Best-effort route category associated with the update.
    public let routeKind: RouteKind
    /// Matched route name or callback pattern when available.
    public let routeName: String?
    /// Telegram update identifier.
    public let updateId: Int
    /// Resolved chat identifier, if present in the update.
    public let chatId: Int64?
    /// Resolved user identifier, if present in the update.
    public let userId: Int64?
    /// When the update was first received by the router.
    public let startedAt: ContinuousClock.Instant
    /// Time elapsed from `startedAt` until the event was emitted.
    public let duration: Duration?
    /// Typed error attached to `.failed` events, when available.
    public let error: (any Error)?
    /// Human-readable error description for failed updates.
    public let errorDescription: String?

    /// Creates a router lifecycle event.
    public init(
        kind: Kind,
        routeKind: RouteKind,
        routeName: String? = nil,
        updateId: Int,
        chatId: Int64?,
        userId: Int64?,
        startedAt: ContinuousClock.Instant = ContinuousClock().now,
        duration: Duration? = nil,
        error: (any Error)? = nil,
        errorDescription: String? = nil
    ) {
        self.kind = kind
        self.routeKind = routeKind
        self.routeName = routeName
        self.updateId = updateId
        self.chatId = chatId
        self.userId = userId
        self.startedAt = startedAt
        self.duration = duration
        self.error = error
        self.errorDescription = errorDescription
    }

    public static func == (lhs: TelerouteEvent, rhs: TelerouteEvent) -> Bool {
        lhs.kind == rhs.kind
            && lhs.routeKind == rhs.routeKind
            && lhs.routeName == rhs.routeName
            && lhs.updateId == rhs.updateId
            && lhs.chatId == rhs.chatId
            && lhs.userId == rhs.userId
            && lhs.duration == rhs.duration
            && lhs.errorDescription == rhs.errorDescription
            // Typed errors are not Equatable in general; compare identity so two
            // events describing the same failure still test as equal when the
            // description matches. The description is the canonical payload.
            && String(reflecting: type(of: lhs.error)) == String(reflecting: type(of: rhs.error))
    }
}

/// Async stream of router events.
///
/// The sequence supports multiple concurrent consumers: every subscriber
/// receives the same events through its own independent iterator. The
/// subscription is registered eagerly when this value is created so events
/// emitted before iteration begins are buffered by the underlying stream.
public struct TelerouteEventSequence: AsyncSequence, Sendable {
    public typealias Element = TelerouteEvent
    public typealias AsyncIterator = AsyncStream<TelerouteEvent>.Iterator

    private let stream: AsyncStream<TelerouteEvent>

    init(stream: AsyncStream<TelerouteEvent>) {
        self.stream = stream
    }

    public func makeAsyncIterator() -> AsyncStream<TelerouteEvent>.Iterator {
        self.stream.makeAsyncIterator()
    }
}

/// Internal broadcast hub that fans emitted events out to every subscriber.
final class TelerouteEventHub: Sendable {
    private struct State: Sendable {
        var subscribers: [UUID: AsyncStream<TelerouteEvent>.Continuation] = [:]
        var isFinished = false
    }

    private let state = Mutex(State())

    /// Registers a new subscriber and returns its stream. Each call registers
    /// a fresh subscription so every consumer gets its own iterator and buffer.
    func subscribe(
        buffering: TelerouteEventBufferingPolicy
    ) -> AsyncStream<TelerouteEvent> {
        let id = UUID()
        let pair = AsyncStream<TelerouteEvent>.makeStream(
            bufferingPolicy: buffering.streamPolicy
        )
        pair.continuation.onTermination = { [weak self] _ in
            self?.removeSubscriber(id: id)
        }

        let shouldFinish = self.state.withLock { state in
            guard state.isFinished == false else { return true }
            state.subscribers[id] = pair.continuation
            return false
        }
        if shouldFinish {
            pair.continuation.finish()
        }
        return pair.stream
    }

    /// Convenience: registers a subscriber and wraps it in a sequence.
    func sequence(
        buffering: TelerouteEventBufferingPolicy
    ) -> TelerouteEventSequence {
        .init(stream: self.subscribe(buffering: buffering))
    }

    func emit(_ event: TelerouteEvent) {
        let continuations = self.state.withLock { Array($0.subscribers.values) }
        for continuation in continuations {
            continuation.yield(event)
        }
    }

    func finish() {
        let continuations = self.state.withLock { state -> [AsyncStream<TelerouteEvent>.Continuation] in
            guard state.isFinished == false else { return [] }
            state.isFinished = true
            let continuations = Array(state.subscribers.values)
            state.subscribers.removeAll()
            return continuations
        }
        // `finish()` invokes `onTermination`; call it after releasing the mutex.
        for continuation in continuations {
            continuation.finish()
        }
    }

    var subscriberCount: Int {
        self.state.withLock { $0.subscribers.count }
    }

    private func removeSubscriber(id: UUID) {
        self.state.withLock { state in
            state.subscribers[id] = nil
        }
    }
}
