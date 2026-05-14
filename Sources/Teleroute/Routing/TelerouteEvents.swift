import AsyncAlgorithms
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
/// The sequence is backed by `AsyncChannel` and is intended for a single
/// observability consumer.
public struct TelerouteEventSequence: AsyncSequence, Sendable {
    public typealias Element = TelerouteEvent

    private let channel: AsyncChannel<TelerouteEvent>

    init(channel: AsyncChannel<TelerouteEvent>) {
        self.channel = channel
    }

    public func makeAsyncIterator() -> AsyncChannel<TelerouteEvent>.Iterator {
        self.channel.makeAsyncIterator()
    }
}

final class TelerouteEventEmitter: Sendable {
    private struct State: Sendable {
        var channel: AsyncChannel<TelerouteEvent>?
    }

    private let state = Mutex(State())

    var events: TelerouteEventSequence {
        let channel = self.state.withLock {
            if let channel = $0.channel {
                return channel
            }
            let channel = AsyncChannel<TelerouteEvent>()
            $0.channel = channel
            return channel
        }
        return .init(channel: channel)
    }

    func emit(_ event: TelerouteEvent) {
        guard let channel = self.state.withLock({ $0.channel }) else {
            return
        }
        Task {
            await channel.send(event)
        }
    }

    func finish() {
        let channel = self.state.withLock {
            let channel = $0.channel
            $0.channel = nil
            return channel
        }
        channel?.finish()
    }
}
