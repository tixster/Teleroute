import Foundation
import Metrics

/// A metrics sink forwarding routing signals to `swift-metrics`.
///
/// Emitted instruments:
/// - `teleroute.updates.received`, `.handled`, `.unmatched`, `.failed`,
///   `.duplicate` — counters dimensioned by `route_kind` (and `route` where
///   one matched);
/// - `teleroute.handler.duration` — a timer for handled and failed routes;
/// - `teleroute.flows.ended` — a counter dimensioned by `flow` and `outcome`
///   (`finished`, `cancelled`, `expired`), with `teleroute.flow.age` timing how
///   long each session lasted.
public struct TelerouteSwiftMetricsSink: TelerouteMetricsSink {
    private let prefix: String

    public init(prefix: String = "teleroute") {
        self.prefix = prefix
    }

    public func recordReceived(
        routeKind: TelerouteEvent.RouteKind, chatId: Int64?, userId: Int64?
    ) async {
        Counter(
            label: "\(self.prefix).updates.received",
            dimensions: [("route_kind", Self.label(for: routeKind))]
        ).increment()
    }

    public func recordSkippedDuplicate(
        routeKind: TelerouteEvent.RouteKind, chatId: Int64?, userId: Int64?
    ) async {
        Counter(
            label: "\(self.prefix).updates.duplicate",
            dimensions: [("route_kind", Self.label(for: routeKind))]
        ).increment()
    }

    public func recordHandled(
        routeKind: TelerouteEvent.RouteKind,
        routeName: String?,
        chatId: Int64?,
        userId: Int64?,
        duration: Duration
    ) async {
        let dimensions = Self.dimensions(routeKind: routeKind, routeName: routeName)
        Counter(label: "\(self.prefix).updates.handled", dimensions: dimensions).increment()
        Timer(label: "\(self.prefix).handler.duration", dimensions: dimensions)
            .recordNanoseconds(Self.nanoseconds(duration))
    }

    public func recordFlowEnded(
        flowID: String,
        step: String,
        outcome: TelerouteFlowOutcome,
        age: Duration,
        chatId: Int64?,
        userId: Int64?
    ) async {
        let dimensions = [
            ("flow", flowID),
            ("outcome", outcome.rawValue),
        ]
        Counter(label: "\(self.prefix).flows.ended", dimensions: dimensions).increment()
        Timer(label: "\(self.prefix).flow.age", dimensions: dimensions)
            .recordNanoseconds(Self.nanoseconds(age))
    }

    public func recordUnmatched(
        routeKind: TelerouteEvent.RouteKind, chatId: Int64?, userId: Int64?
    ) async {
        Counter(
            label: "\(self.prefix).updates.unmatched",
            dimensions: [("route_kind", Self.label(for: routeKind))]
        ).increment()
    }

    public func recordFailed(
        routeKind: TelerouteEvent.RouteKind,
        routeName: String?,
        chatId: Int64?,
        userId: Int64?,
        duration: Duration,
        error: any Error
    ) async {
        let dimensions = Self.dimensions(routeKind: routeKind, routeName: routeName)
        Counter(label: "\(self.prefix).updates.failed", dimensions: dimensions).increment()
        Timer(label: "\(self.prefix).handler.duration", dimensions: dimensions)
            .recordNanoseconds(Self.nanoseconds(duration))
    }

    private static func dimensions(
        routeKind: TelerouteEvent.RouteKind,
        routeName: String?
    ) -> [(String, String)] {
        var dimensions = [("route_kind", self.label(for: routeKind))]
        if let routeName {
            dimensions.append(("route", routeName))
        }
        return dimensions
    }

    private static func label(for routeKind: TelerouteEvent.RouteKind) -> String {
        switch routeKind {
        case .command: "command"
        case .callback: "callback"
        case .flow: "flow"
        case .message: "message"
        case let .update(kind): kind.rawValue
        case .unknown: "unknown"
        }
    }

    private static func nanoseconds(_ duration: Duration) -> Int64 {
        duration.components.seconds * 1_000_000_000
            + duration.components.attoseconds / 1_000_000_000
    }
}
