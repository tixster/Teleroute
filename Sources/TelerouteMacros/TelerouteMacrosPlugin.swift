import SwiftCompilerPlugin
import SwiftSyntaxMacros

/// Compiler plugin entry point exposing the Teleroute macros.
@main
struct TelerouteMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        TelerouteCallbackMacro.self,
        TelerouteCommandMacro.self,
    ]
}
