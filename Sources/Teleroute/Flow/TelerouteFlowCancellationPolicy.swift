import Foundation

/// Controls what happens to an active flow session when a command arrives that
/// does not match any flow-local command route for the current step.
///
/// Telegram delivers unrelated commands (for example `/help` or `/lang`) to the
/// same chat while a flow is in progress. By default `Teleroute` cancels the
/// session in that situation so the next message is no longer captured by the
/// flow. The policies below let callers opt out of that behavior.
///
/// This is the router-wide setting. ``TelerouteFlowGroup/onInterrupt(_:)``
/// overrides it for one flow and can do things no policy can — suspend the
/// session, or answer the command and stop it reaching its own route.
///
/// > Note: the scope really is only unmatched commands.
/// ``TelerouteConfiguration/flowSessionTTL`` expires idle sessions regardless
/// of the policy set here, and starting a flow still replaces whatever session
/// held the chat.
public enum TelerouteFlowCancellationPolicy: Sendable {
    /// Cancels the active flow session when any command fails to match a
    /// flow-local command route for the current step.
    ///
    /// This is the historical behavior and the default.
    case cancelOnAnyUnmatchedCommand

    /// Leaves the flow session in place when a command does not match the
    /// current step. The update falls through to regular command routes, and
    /// the flow keeps capturing subsequent messages.
    ///
    /// Cancellation then only happens where a handler asks for it —
    /// ``TelerouteFlowContext/finish()``, ``TelerouteFlowContext/cancel()``, or
    /// ``TelerouteRequestContext/cancelFlow()``.
    case preserveOnUnmatchedCommand
}

extension TelerouteFlowCancellationPolicy {
    /// Returns `true` when an unmatched command arriving during a flow should
    /// tear down the active session.
    var cancelsSessionOnUnmatchedCommand: Bool {
        switch self {
        case .cancelOnAnyUnmatchedCommand:
            return true
        case .preserveOnUnmatchedCommand:
            return false
        }
    }
}
