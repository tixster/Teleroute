import SwiftSyntax
import SwiftSyntaxMacros

public enum TelerouteMacroError: Error, CustomStringConvertible {
    case missingPath
    case unsupportedDeclaration
    case callbackParameterMissing(String)
    case callbackParameterMustBeString(name: String, type: String)
    case callbackPropertyNotInPath(String)

    public var description: String {
        switch self {
        case .missingPath:
            "Teleroute macros require a path string argument"
        case .unsupportedDeclaration:
            "Teleroute macros can only be attached to structs"
        case let .callbackParameterMissing(name):
            "Callback path parameter '{\(name)}' requires a stored 'let \(name): String' property"
        case let .callbackParameterMustBeString(name, type):
            "Callback path parameter '{\(name)}' must use a required String property, not '\(type)'"
        case let .callbackPropertyNotInPath(name):
            "Callback property '\(name)' is not present as a placeholder in the callback path"
        }
    }
}
