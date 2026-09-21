import Foundation
import TelegramBotAPI

// MARK: - Why a session ended

/// Why a flow session ended.
///
/// Three of these happen *to* a flow rather than being asked for by it — a
/// command it does not handle arrives, its TTL runs out, or another flow takes
/// the chat. Register ``TelerouteFlowGroup/onEnd(_:)`` to react.
public enum TelerouteFlowEndReason: Sendable, Equatable {
    /// A step called ``TelerouteFlowContext/finish()``.
    case finished
    /// A handler called ``TelerouteFlowContext/cancel()`` or
    /// ``TelerouteRequestContext/cancelFlow()``.
    case cancelled
    /// A command the flow does not handle at the current step arrived, and the
    /// session was cancelled rather than kept.
    case interrupted(command: String)
    /// The session passed its TTL without activity.
    case expired
    /// Another flow — or a restart of this one — took over the chat/user scope.
    case replaced(by: String)

    /// How this ending is reported to ``TelerouteMetricsSink``.
    public var outcome: TelerouteFlowOutcome {
        switch self {
        case .finished: .finished
        case .cancelled, .interrupted, .replaced: .cancelled
        case .expired: .expired
        }
    }
}

// MARK: - What to do about an interrupting command

/// What a flow wants done with a command it does not handle at this step.
///
/// Returned from ``TelerouteFlowGroup/onInterrupt(_:)``. Without that hook the
/// configured ``TelerouteFlowCancellationPolicy`` decides, exactly as before.
public enum TelerouteFlowInterruption: Sendable {
    /// End the session, then let the command route normally. This is what
    /// ``TelerouteFlowCancellationPolicy/cancelOnAnyUnmatchedCommand`` does.
    case cancel
    /// Keep the session but stop capturing until
    /// ``TelerouteRequestContext/resumeFlow()``; the command routes normally.
    case suspend
    /// Leave the session active and capturing; the command routes normally too.
    case keep
    /// Answer from the flow and stop there — the command does **not** reach its
    /// own route. Use it to tell the user the conversation is still open.
    case handled(TelerouteResponse)
}

// MARK: - The context a lifecycle hook receives

/// The context handed to ``TelerouteFlowGroup/onEnd(_:)`` and
/// ``TelerouteFlowGroup/onInterrupt(_:)``.
///
/// A full ``TelerouteRequestContext`` — `reply`, `send`, media, `logger`, and
/// the rest — over the update that ended the session, plus a snapshot of the
/// session itself in ``endedSession``.
///
/// It is deliberately *not* a ``TelerouteFlowContext``: by the time a hook
/// runs, the session is being torn down, so `transition` and `update` would
/// only throw. Read the final values from ``endedSession`` instead.
public struct TelerouteFlowEndContext: TelerouteRequestContext {
    public let coreContext: TelerouteContext
    /// The session as it was when it ended.
    public let endedSession: TelerouteFlowSession

    init(coreContext: TelerouteContext, endedSession: TelerouteFlowSession) {
        self.coreContext = coreContext
        self.endedSession = endedSession
    }

    /// Values collected before the session ended.
    public var values: TelerouteFlowValues {
        self.endedSession.values
    }
}

// MARK: - Registered hooks

/// Closure invoked when a flow session ends. See
/// ``TelerouteFlowGroup/onEnd(_:)``.
public typealias TelerouteFlowEndHandler = @Sendable (
    _ context: TelerouteFlowEndContext,
    _ reason: TelerouteFlowEndReason
) async -> Void

/// Closure deciding what to do with a command the flow does not handle. See
/// ``TelerouteFlowGroup/onInterrupt(_:)``.
public typealias TelerouteFlowInterruptHandler = @Sendable (
    _ context: TelerouteFlowEndContext,
    _ command: TelerouteCommandMatch
) async -> TelerouteFlowInterruption

/// Lifecycle closures registered by a flow's `boot`.
///
/// Stored per flow id rather than per step, and as closures rather than on the
/// flow instance — the router never retains the instance.
struct TelerouteFlowHooks: Sendable {
    var onEnd: TelerouteFlowEndHandler?
    var onInterrupt: TelerouteFlowInterruptHandler?

    var isEmpty: Bool {
        self.onEnd == nil && self.onInterrupt == nil
    }
}
