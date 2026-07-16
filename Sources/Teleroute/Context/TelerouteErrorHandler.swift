import Foundation

/// User-supplied handler invoked when a route or middleware throws.
///
/// Attach one through ``Teleroute/Configuration`` to centralize error recovery,
/// user-facing replies, or retry logic. When the handler is `nil`, errors are
/// only logged and surfaced through ``Teleroute/eventStream(buffering:)``.
public typealias TelerouteErrorHandler = @Sendable (any Error, TelerouteContext) async -> Void
