import Foundation

/// Synthesizes `TelerouteCallback` conformance for a struct from a path pattern.
///
/// The macro extracts `{param}` segments from the path and matches them to
/// stored `let` properties of the same name, generating `path`, the decode
/// initializer, the encode property, and a memberwise init.
///
/// ```swift
/// @TelerouteCallback("orders/{orderID}/approve")
/// struct ApproveOrderCallback {
///     let orderID: String
/// }
/// ```
@attached(extension, conformances: TelerouteCallback)
@attached(member, names: named(path), named(init(parameters:)), named(parameters), arbitrary)
public macro TelerouteCallback(_ path: String) = #externalMacro(
    module: "TelerouteMacros",
    type: "TelerouteCallbackMacro"
)

/// Synthesizes `TelerouteCommand` conformance for a struct from its command path.
///
/// Stored `let` properties are decoded from the command match by name and then
/// by position. Optional (`String?`) properties use `command.get(_:at:)`.
///
/// ```swift
/// @TelerouteCommand("ban")
/// struct BanCommand {
///     let userID: String
///     let reason: String?
/// }
/// ```
@attached(extension, conformances: TelerouteCommand)
@attached(member, names: named(path), named(init(command:)), arbitrary)
public macro TelerouteCommand(_ path: String) = #externalMacro(
    module: "TelerouteMacros",
    type: "TelerouteCommandMacro"
)
