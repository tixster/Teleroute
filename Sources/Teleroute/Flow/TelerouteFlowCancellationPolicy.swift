import Foundation

/// Controls what happens to an active flow session when a command arrives that
/// does not match any flow-local command route for the current step.
///
/// Telegram delivers unrelated commands (for example `/help` or `/lang`) to the
/// same chat while a flow is in progress. By default `Teleroute` cancels the
/// session in that situation so the next message is no longer captured by the
/// flow. The policies below let callers opt out of that behavior.
public enum TelerouteFlowCancellationPolicy: Sendable {
    /// Cancels the active flow session when any command fails to match a
    /// flow-local command route for the current step.
    ///
    /// This is the historical behavior and the default.
    case cancelOnAnyUnmatchedCommand

    /// Leaves the flow session in place when a command does not match the
    /// current step. The update falls through to regular command routes, and
    /// the flow keeps capturing subsequent messages.
    case preserveOnUnmatchedCommand

    /// Never cancels a flow session automatically. Use this when cancellation
    /// must always be explicit, for example through `context.cancelFlow()`.
    case manual
}

extension TelerouteFlowCancellationPolicy {
    /// Returns `true` when an unmatched command arriving during a flow should
    /// tear down the active session.
    var cancelsSessionOnUnmatchedCommand: Bool {
        switch self {
        case .cancelOnAnyUnmatchedCommand:
            return true
        case .preserveOnUnmatchedCommand, .manual:
            return false
        }
    }
}
