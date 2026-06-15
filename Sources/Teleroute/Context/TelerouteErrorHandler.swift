import Foundation

/// User-supplied handler invoked when a route or middleware throws.
///
/// Attach one via the `onError` parameter of ``Teleroute/init(bot:logger:onError:)``
/// to centralize error recovery, user-facing replies, or retry logic. When the
/// handler is `nil`, errors are only logged and surfaced through ``Teleroute/events``.
public typealias TelerouteErrorHandler = @Sendable (any Error, TelerouteContext) async -> Void
