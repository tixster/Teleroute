import Foundation

/// Errors thrown by router helpers for missing update data or invalid route usage.
public enum TelerouteError: LocalizedError, Sendable {
    case callbackQueryMissing
    case callbackRouteNotRegistered(String)
    case callbackRouteRouterMismatch(String)
    /// The callback value matches more than one registered route, so the
    /// scope that should render it cannot be inferred.
    case ambiguousCallbackRoute(String, matches: [String])
    /// Rendered callback data exceeds Telegram's 64-byte limit.
    case callbackDataTooLong(String, bytes: Int)
    case chatTargetMissing
    /// The update carries no Telegram user, so a user-scoped operation has no
    /// target.
    case userTargetMissing
    case commandMatchMissing
    case flowControllerMissing
    case flowScopeMissing
    /// A flow step tried to advance a session that has already ended.
    case flowSessionEnded(flowID: String)
    /// A flow step tried to advance a session that another flow now owns.
    case flowSessionReplaced(expected: String, found: String)
    case invalidFlowStep(flowID: String, step: String)
    /// A button carrying an inline handler was rendered without a request
    /// context, so there is nowhere to park the handler.
    case inlineActionContextMissing
    /// A button carrying an inline handler was rendered while inline
    /// actions are disabled.
    case inlineActionsDisabled
    /// The context was not produced by a running router, so it carries no
    /// route scope to validate keyboards against.
    case keyboardScopeMissing
    case messageTargetMissing
    case missingParameter(String)
    case invalidParameter(name: String, value: String)
    case duplicatePublishedCommand(String, visibility: String)
    case missingPublishedCommandDescription(String)

    public var errorDescription: String? {
        switch self {
        case .callbackQueryMissing:
            "Callback query is missing in the current update."
        case let .callbackRouteNotRegistered(path):
            "Callback route '\(path)' is not registered in this route scope."
        case let .callbackRouteRouterMismatch(path):
            "Callback route '\(path)' belongs to a different Teleroute router."
        case let .ambiguousCallbackRoute(path, matches):
            """
            Callback '\(path)' is registered on \(matches.count) routes \
            (\(matches.joined(separator: ", "))), so the one to link cannot be \
            inferred. Render the button from its route handle instead.
            """
        case let .callbackDataTooLong(data, bytes):
            """
            Callback data '\(data)' is \(bytes) bytes; Telegram allows at most 64. \
            Shorten the route path or its parameter values.
            """
        case .chatTargetMissing:
            "Unable to determine the target chat for this update."
        case .userTargetMissing:
            "This update carries no Telegram user."
        case .commandMatchMissing:
            "The matched command is missing from the route context."
        case .flowControllerMissing:
            "Flow support is unavailable for this context."
        case .flowScopeMissing:
            "Unable to determine the flow scope for this update."
        case let .flowSessionEnded(flowID):
            """
            Flow '\(flowID)' has no active session for this chat and user, so \
            it cannot advance. A handler that ends a session with finish() or \
            cancelFlow() must not transition afterwards.
            """
        case let .flowSessionReplaced(expected, found):
            """
            Flow '\(expected)' cannot advance this scope: flow '\(found)' is \
            active here now.
            """
        case let .invalidFlowStep(flowID, step):
            "Flow '\(flowID)' does not define a step named '\(step)'."
        case .inlineActionContextMissing:
            """
            A button with an inline handler needs the request context that is \
            rendering it. Build the keyboard from a handler — \
            `Reply(…).keyboard { … }` or `context.keyboard { … }` — rather \
            than from the router at registration time.
            """
        case .inlineActionsDisabled:
            """
            Buttons with inline handlers require \
            TelerouteConfiguration.inlineActions to be `.enabled(…)`.
            """
        case .keyboardScopeMissing:
            """
            This context carries no route scope, so keyboards cannot be validated. \
            Render through the router or a route handle instead.
            """
        case .messageTargetMissing:
            "Unable to determine the target message for this update."
        case let .invalidParameter(name, value):
            "Parameter '\(name)' has an invalid value '\(value)'"
        case let .missingParameter(name):
            "Route parameter '\(name)' is missing."
        case let .duplicatePublishedCommand(name, visibility):
            "Command '\(name)' is registered more than once for published visibility '\(visibility)' with different descriptions."
        case let .missingPublishedCommandDescription(name):
            "Command '\(name)' does not define a published command description."
        }
    }
}
