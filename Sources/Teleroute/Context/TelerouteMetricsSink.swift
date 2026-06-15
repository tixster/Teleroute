import Foundation

/// Optional metrics sink notified by ``Teleroute`` as updates are processed.
///
/// Implement this protocol to forward routing counts and handler durations to
/// your observability backend (Prometheus, OTel, etc.). All methods have
/// default no-op implementations, so conforming types only need to override
/// the callbacks they care about.
public protocol TelerouteMetricsSink: Sendable {
    /// Called once for every update received by the router.
    func recordReceived(routeKind: TelerouteEvent.RouteKind, chatId: Int64?, userId: Int64?) async

    /// Called when a duplicate update was suppressed by replay protection.
    func recordSkippedDuplicate(routeKind: TelerouteEvent.RouteKind, chatId: Int64?, userId: Int64?) async

    /// Called when a route handled the update.
    func recordHandled(
        routeKind: TelerouteEvent.RouteKind,
        routeName: String?,
        chatId: Int64?,
        userId: Int64?,
        duration: Duration
    ) async

    /// Called when no route matched the update.
    func recordUnmatched(routeKind: TelerouteEvent.RouteKind, chatId: Int64?, userId: Int64?) async

    /// Called when a route or middleware threw.
    func recordFailed(
        routeKind: TelerouteEvent.RouteKind,
        routeName: String?,
        chatId: Int64?,
        userId: Int64?,
        duration: Duration,
        error: any Error
    ) async
}

public extension TelerouteMetricsSink {
    func recordReceived(routeKind: TelerouteEvent.RouteKind, chatId: Int64?, userId: Int64?) async {}
    func recordSkippedDuplicate(routeKind: TelerouteEvent.RouteKind, chatId: Int64?, userId: Int64?) async {}
    func recordHandled(routeKind: TelerouteEvent.RouteKind, routeName: String?, chatId: Int64?, userId: Int64?, duration: Duration) async {}
    func recordUnmatched(routeKind: TelerouteEvent.RouteKind, chatId: Int64?, userId: Int64?) async {}
    func recordFailed(routeKind: TelerouteEvent.RouteKind, routeName: String?, chatId: Int64?, userId: Int64?, duration: Duration, error: any Error) async {}
}

/// A metrics sink that ignores every callback. Used as the default.
public struct TelerouteNoOpMetricsSink: TelerouteMetricsSink {
    public init() {}
}
