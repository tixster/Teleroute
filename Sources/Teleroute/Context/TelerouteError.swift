import Foundation

/// Errors thrown by router helpers when the current update does not contain the expected data.
public enum TelerouteError: LocalizedError, Sendable {
    case callbackQueryMissing
    case chatTargetMissing
    case flowControllerMissing
    case flowScopeMissing
    case invalidFlowStep(flowID: String, step: String)
    case messageTargetMissing
    case missingParameter(String)
    case duplicatePublishedCommand(String, visibility: String)
    case missingPublishedCommandDescription(String)

    public var errorDescription: String? {
        switch self {
        case .callbackQueryMissing:
            "Callback query is missing in the current update."
        case .chatTargetMissing:
            "Unable to determine the target chat for this update."
        case .flowControllerMissing:
            "Flow support is unavailable for this context."
        case .flowScopeMissing:
            "Unable to determine the flow scope for this update."
        case let .invalidFlowStep(flowID, step):
            "Flow '\(flowID)' does not define a step named '\(step)'."
        case .messageTargetMissing:
            "Unable to determine the target message for this update."
        case let .missingParameter(name):
            "Route parameter '\(name)' is missing."
        case let .duplicatePublishedCommand(name, visibility):
            "Command '\(name)' is registered more than once for published visibility '\(visibility)' with different descriptions."
        case let .missingPublishedCommandDescription(name):
            "Command '\(name)' does not define a published command description."
        }
    }
}
