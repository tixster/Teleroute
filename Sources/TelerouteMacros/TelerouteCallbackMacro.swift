import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

/// `@TelerouteCallback("path/{param}")` synthesizes `TelerouteCallback` conformance.
///
/// Extracts `{param}` segments from the path and matches them to stored `let`
/// properties of the same name to generate `path`, `init(parameters:)`,
/// `var parameters`, and a memberwise init.
public struct TelerouteCallbackMacro: ExtensionMacro, MemberMacro {
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
        // `@attached(extension, conformances:)` passes the list of conformances
        // here; the macro must emit an extension that actually conforms to them.
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
        let parameters = Self.parameterNames(from: path)
        let orderedProperties = Self.storedProperties(from: declaration)
        let propertyLookup = Dictionary(orderedProperties, uniquingKeysWith: { first, _ in first })

        var members: [DeclSyntax] = []

        members.append("public static let path: String = \(literal: path)")

        let initLines = parameters.map { name -> String in
            let optional = propertyLookup[name]?.isOptional ?? false
            if optional {
                return "self.\(name) = parameters.get(\"\(name)\")"
            }
            return "self.\(name) = try parameters.require(\"\(name)\")"
        }.joined(separator: "\n")
        members.append(
            #"""
            public init(parameters: TelerouteParameters) throws {
                \#(raw: initLines)
            }
            """#
        )

        let encodeEntries = parameters.map { name in "[\"\(name)\": self.\(name)]" }
            .joined(separator: ", ")
        let encodeBody = encodeEntries.isEmpty ? "[:]" : encodeEntries
        members.append(
            #"""
            public var parameters: [String: String] {
                get throws { \#(raw: encodeBody) }
            }
            """#
        )

        let memberwiseArgs = orderedProperties.map { name, info in "\(name): \(info.type)" }
            .joined(separator: ", ")
        let memberwiseAssign = orderedProperties.map { name, _ in "self.\(name) = \(name)" }
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

    // MARK: - Parsing helpers

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

    private static func parameterNames(from path: String) -> [String] {
        path.split(separator: "/").compactMap { component in
            let trimmed = String(component)
            guard trimmed.hasPrefix("{"), trimmed.hasSuffix("}"), trimmed.count > 2 else {
                return nil
            }
            return String(trimmed.dropFirst().dropLast())
        }
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
            var typeText = binding.typeAnnotation?.type.trimmedDescription ?? "String"
            var isOptional = false
            if typeText.hasSuffix("?") {
                isOptional = true
                typeText = String(typeText.dropLast()).trimmingCharacters(in: .whitespaces)
            }
            result.append((name, PropertyInfo(type: typeText, isOptional: isOptional)))
        }
        return result
    }
}
