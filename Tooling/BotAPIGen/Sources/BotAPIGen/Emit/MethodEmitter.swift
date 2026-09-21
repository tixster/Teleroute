import Foundation

/// Emits the client layer: one flat method per Bot API operation.
///
/// Because the request encoder is ours, each wrapper is one `set` per
/// documented parameter and a single `perform` — no per-template branching, no
/// `if let` ladder, and no separate multipart body. `sendPhoto` is about a
/// third of the size it was under the OpenAPI-generated client.
struct MethodEmitter {
    let spec: ApiSpec

    func write(to directory: URL) throws -> Int {
        var groups: [String: [ApiMethod]] = [:]
        for method in self.spec.methods {
            groups[method.group, default: []].append(method)
        }

        var written: Set<String> = []
        for (group, methods) in groups.sorted(by: { $0.key < $1.key }) {
            var printer = SwiftPrinter()
            printer.raw(GeneratedFile.header(spec: self.spec))
            printer.line("import Foundation")
            printer.line("import TelegramBotAPI")
            printer.line()
            printer.block("public extension TelegramBotClient") { printer in
                for (offset, method) in methods.enumerated() {
                    if offset > 0 { printer.line() }
                    self.emit(method, into: &printer)
                }
            }
            let name = "TelegramBotClient+\(group).swift"
            try GeneratedFile.write(printer.text, named: name, in: directory)
            written.insert(name)
        }

        try GeneratedFile.write(
            UpdateKindEmitter(spec: self.spec).render(),
            named: "UpdateKind.swift",
            in: directory
        )
        written.insert("UpdateKind.swift")

        try GeneratedFile.prune(directory: directory, keeping: written)
        return written.count
    }

    private func emit(_ method: ApiMethod, into printer: inout SwiftPrinter) {
        printer.doc(method.doc)
        printer.line("@discardableResult")

        // Required parameters first, then optionals — each group in
        // documentation order, as the previous generator did.
        let ordered = method.parameters.filter { !$0.field.isOptional }
            + method.parameters.filter(\.field.isOptional)

        if ordered.isEmpty {
            printer.line("func \(method.name)() async throws -> \(method.returnType.swiftTypeName) {")
        } else {
            printer.line("func \(method.name)(")
            for (offset, parameter) in ordered.enumerated() {
                let comma = offset == ordered.count - 1 ? "" : ","
                printer.line("    \(Self.declaration(of: parameter))\(comma)")
            }
            printer.line(") async throws -> \(method.returnType.swiftTypeName) {")
        }
        printer.indenting { self.emitBody(method, into: &$0) }
        printer.line("}")
    }

    private func emitBody(_ method: ApiMethod, into printer: inout SwiftPrinter) {
        if let pacing = Self.pacingArgument(for: method) {
            printer.line("try await self.pace(chatId: \(pacing))")
        }
        let binding = method.parameters.isEmpty ? "let" : "var"
        printer.line("\(binding) request = TelegramRequest(\"\(method.name)\")")
        for parameter in method.parameters {
            printer.line(
                "request.set(\"\(parameter.field.wireName)\", \(Self.argument(for: parameter)))"
            )
        }
        switch method.returnType {
        case .messageOrBool:
            printer.line("return try await self.performMessageOrFlag(request)")
        case .value:
            printer.line("return try await self.perform(request)")
        }
    }

    // MARK: - Parameters

    /// Teleroute's own vocabulary replaces the documentation's untyped strings
    /// and file placeholders at the call site.
    static func swiftType(of parameter: ApiParameter) -> String {
        switch parameter.sugar {
        case .fileInput: "FileInput"
        case .parseMode: "ParseMode"
        case .chatAction: "ChatAction"
        case .none: parameter.field.type.swiftTypeName
        }
    }

    static func declaration(of parameter: ApiParameter) -> String {
        let type = self.swiftType(of: parameter) + (parameter.field.isOptional ? "?" : "")
        return "\(parameter.field.swiftName): \(type)"
            + (parameter.field.isOptional ? " = nil" : "")
    }

    static func argument(for parameter: ApiParameter) -> String {
        let name = parameter.field.swiftName
        switch parameter.sugar {
        case .parseMode, .chatAction:
            return parameter.field.isOptional ? "\(name)?.rawValue" : "\(name).rawValue"
        case .fileInput, .none:
            return name
        }
    }

    /// Per-chat pacing applies to anything addressed at a chat, except the
    /// long-polling call, which must never be throttled.
    static func pacingArgument(for method: ApiMethod) -> String? {
        guard method.name != "getUpdates" else { return nil }
        guard let parameter = method.parameters.first(where: { $0.field.wireName == "chat_id" })
        else { return nil }
        let name = parameter.field.swiftName
        switch (parameter.field.type, parameter.field.isOptional) {
        case (.chatId, _): return name
        case (.integer, false): return ".id(\(name))"
        case (.integer, true): return "\(name).map(ChatId.id)"
        default: return nil
        }
    }
}
