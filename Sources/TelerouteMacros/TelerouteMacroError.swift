import SwiftSyntax
import SwiftSyntaxMacros

public enum TelerouteMacroError: Error, CustomStringConvertible {
    case missingPath
    case unsupportedDeclaration

    public var description: String {
        switch self {
        case .missingPath:
            "Teleroute macros require a path string argument"
        case .unsupportedDeclaration:
            "Teleroute macros can only be attached to structs"
        }
    }
}
