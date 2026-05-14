import Foundation
import Synchronization

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
    /// Human-readable error description for failed updates.
    public let errorDescription: String?
}

/// Async stream of router events.
///
/// The sequence is intended for a single observability consumer.
public struct TelerouteEventSequence: AsyncSequence, Sendable {
    public typealias Element = TelerouteEvent

    private let stream: AsyncStream<TelerouteEvent>

    init(stream: AsyncStream<TelerouteEvent>) {
        self.stream = stream
    }

    public func makeAsyncIterator() -> AsyncStream<TelerouteEvent>.Iterator {
        self.stream.makeAsyncIterator()
    }
}

final class TelerouteEventEmitter: Sendable {
    private struct State: Sendable {
        var stream: AsyncStream<TelerouteEvent>?
        var continuation: AsyncStream<TelerouteEvent>.Continuation?
    }

    private let state = Mutex(State())

    var events: TelerouteEventSequence {
        let stream = self.state.withLock {
            if let stream = $0.stream {
                return stream
            }
            var continuation: AsyncStream<TelerouteEvent>.Continuation?
            let stream = AsyncStream<TelerouteEvent> {
                continuation = $0
            }
            $0.stream = stream
            $0.continuation = continuation
            return stream
        }
        return .init(stream: stream)
    }

    func emit(_ event: TelerouteEvent) {
        self.state.withLock { $0.continuation }?.yield(event)
    }

    func finish() {
        let continuation = self.state.withLock {
            let continuation = $0.continuation
            $0.stream = nil
            $0.continuation = nil
            return continuation
        }
        continuation?.finish()
    }
}
