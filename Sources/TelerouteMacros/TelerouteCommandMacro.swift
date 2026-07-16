import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

/// `@TelerouteCommand("name")` synthesizes `TelerouteCommand` conformance.
///
/// Stored `let` properties are decoded from the command match by name then by
/// position. Optional (`String?`) properties use `command.get(_:at:)`.
public struct TelerouteCommandMacro: ExtensionMacro, MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard protocols.isEmpty == false else {
            return []
        }
        let conformanceList = protocols.map(\.description).joined(separator: ", ")
        let ext = try ExtensionDeclSyntax("extension \(type.trimmed): \(raw: conformanceList) {}")
        return [ext]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let path = Self.path(from: node) else {
            throw TelerouteMacroError.missingPath
        }
        let properties = Self.storedProperties(from: declaration)

        var members: [DeclSyntax] = []
        members.append("public static let path: String = \(literal: path)")

        let decodeLines = properties.enumerated().map { index, element -> String in
            let (name, info) = element
            if info.isOptional {
                return "self.\(name) = command.get(\"\(name)\", at: \(index))"
            }
            return "self.\(name) = try command.require(\"\(name)\", at: \(index))"
        }.joined(separator: "\n")
        members.append(
            #"""
            public init(command: TelerouteCommandMatch) throws {
                \#(raw: decodeLines)
            }
            """#
        )

        let memberwiseArgs = properties.map { name, info in "\(name): \(info.type)" }
            .joined(separator: ", ")
        let memberwiseAssign = properties.map { name, _ in "self.\(name) = \(name)" }
            .joined(separator: "\n")
        members.append(
            #"""
            public init(\#(raw: memberwiseArgs)) {
                \#(raw: memberwiseAssign)
            }
            """#
        )

        return members
    }

    private static func path(from node: AttributeSyntax) -> String? {
        guard case let .argumentList(arguments) = node.arguments else { return nil }
        for argument in arguments {
            if let string = argument.expression.as(StringLiteralExprSyntax.self) {
                return string.segments.compactMap { segment in
                    if case let .stringSegment(segment) = segment {
                        return segment.content.text
                    }
                    return nil
                }.joined()
            }
        }
        return nil
    }

    private struct PropertyInfo {
        let type: String
        let isOptional: Bool
    }

    private static func storedProperties(from declaration: any DeclSyntaxProtocol) -> [(String, PropertyInfo)] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else { return [] }
        var result: [(String, PropertyInfo)] = []
        for member in structDecl.memberBlock.members {
            guard let variable = member.decl.as(VariableDeclSyntax.self) else { continue }
            guard variable.bindingSpecifier.text == "let",
                  variable.bindings.count == 1,
                  let binding = variable.bindings.first,
                  binding.initializer?.value == nil,
                  let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
                continue
            }
            let name = pattern.identifier.text
            let typeText = binding.typeAnnotation?.type.trimmedDescription ?? "String"
            let isOptional = typeText.hasSuffix("?")
            result.append((name, PropertyInfo(type: typeText, isOptional: isOptional)))
        }
        return result
    }
}
