import Foundation

/// Emits the model layer: one file per documented type, grouped into folders by
/// the documentation section it came from.
///
/// The generated files import nothing. `Codable`, `Hashable` and `Sendable` are
/// all in the standard library, and importing Foundation is what would make
/// flat top-level names risky — `Data`, `Operation`, `Progress` and `Timer` are
/// all names Telegram could plausibly use one day.
struct TypeEmitter {
    let spec: ApiSpec

    func write(to directory: URL) throws -> Int {
        var written: Set<String> = []

        for type in self.spec.types {
            var printer = SwiftPrinter()
            printer.raw(GeneratedFile.header(spec: self.spec))
            self.emit(type, into: &printer)
            let path = "\(Self.folder(for: type.section))/\(type.name).swift"
            try GeneratedFile.write(printer.text, named: path, in: directory)
            written.insert(path)
        }

        let valueEnums = ValueEnumEmitter(spec: self.spec)
        for enumeration in self.spec.valueEnums {
            let path = "Values/\(enumeration.name).swift"
            try GeneratedFile.write(valueEnums.render(enumeration), named: path, in: directory)
            written.insert(path)
        }

        for file in SupportEmitter(spec: self.spec).render() {
            try GeneratedFile.write(file.contents, named: file.path, in: directory)
            written.insert(file.path)
        }

        try GeneratedFile.prune(directory: directory, keeping: written)
        return written.count
    }

    /// `Available types` → `AvailableTypes`, `Rich messages` → `RichMessages`.
    static func folder(for section: String) -> String {
        section.split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined()
    }

    private func emit(_ type: ApiType, into printer: inout SwiftPrinter) {
        switch type.shape {
        case let .object(fields):
            self.emitStruct(type, fields: fields, into: &printer)
        case .union:
            UnionEmitter(spec: self.spec).emit(type, into: &printer)
        case .empty:
            printer.doc(type.doc)
            printer.block("public struct \(type.name): Codable, Hashable, Sendable") {
                $0.line("public init() {}")
            }
        }
    }

    private func emitStruct(_ type: ApiType, fields: [ApiField], into printer: inout SwiftPrinter) {
        printer.doc(type.doc)
        printer.block("public struct \(type.name): Codable, Hashable, Sendable") { printer in
            for (offset, field) in fields.enumerated() {
                if offset > 0 { printer.line() }
                let stored = Self.swiftType(of: field)
                if field.needsBoxing {
                    // The field either closes a value-type cycle or references
                    // a type too large to copy inline, so its storage goes
                    // behind a box while the public property stays a plain
                    // value.
                    printer.line("private var \(field.swiftName)Box: \(Self.boxedType(of: field))")
                    printer.doc(field.doc)
                    printer.block("public var \(field.swiftName): \(stored)") { printer in
                        if field.isOptional {
                            printer.line("get { self.\(field.swiftName)Box?.value }")
                            printer.line(
                                "set { self.\(field.swiftName)Box = newValue.map(_IndirectBox.init) }"
                            )
                        } else {
                            printer.line("get { self.\(field.swiftName)Box.value }")
                            printer.line("set { self.\(field.swiftName)Box = _IndirectBox(newValue) }")
                        }
                    }
                } else {
                    printer.doc(field.doc)
                    printer.line("public var \(field.swiftName): \(stored)")
                }
            }

            printer.line()
            self.emitInit(fields: fields, into: &printer)
            printer.line()
            Self.emitCodingKeys(fields: fields, into: &printer)
        }
    }

    /// Parameter order follows the documentation, not required-first.
    ///
    /// That is deliberate: it matches the order the previous pipeline produced,
    /// so existing construction sites keep compiling.
    private func emitInit(fields: [ApiField], into printer: inout SwiftPrinter) {
        guard !fields.isEmpty else {
            printer.line("public init() {}")
            return
        }
        printer.line("public init(")
        let parameters = fields.map { field in
            "\(field.swiftName): \(Self.swiftType(of: field))" + Self.defaultValue(for: field)
        }
        for (offset, parameter) in parameters.enumerated() {
            printer.line("    \(parameter)\(offset == parameters.count - 1 ? "" : ",")")
        }
        printer.block(")") { printer in
            for field in fields {
                if field.needsBoxing {
                    printer.line(
                        field.isOptional
                            ? "self.\(field.swiftName)Box = \(field.swiftName).map(_IndirectBox.init)"
                            : "self.\(field.swiftName)Box = _IndirectBox(\(field.swiftName))"
                    )
                } else {
                    printer.line("self.\(field.swiftName) = \(field.swiftName)")
                }
            }
        }
    }

    /// Coding keys map the *stored* property to the wire name, so a boxed field
    /// still gets synthesised `Codable` conformance.
    static func emitCodingKeys(fields: [ApiField], into printer: inout SwiftPrinter) {
        printer.block("public enum CodingKeys: String, CodingKey") { printer in
            for field in fields {
                let stored = field.needsBoxing ? "\(field.swiftName)Box" : field.swiftName
                if stored == field.wireName {
                    printer.line("case \(stored)")
                } else {
                    printer.line("case \(stored) = \"\(field.wireName)\"")
                }
            }
        }
    }

    /// The initialiser default for a field, when it has an obvious one.
    ///
    /// Optionals default to `nil`. A union variant's discriminator defaults to
    /// the literal the documentation says it always carries — writing
    /// `BotCommandScopeDefault(type: "default")` conveys nothing the type name
    /// does not already say.
    static func defaultValue(for field: ApiField) -> String {
        if field.isOptional { return " = nil" }
        guard let constant = field.constantValue else { return "" }
        switch field.type {
        case .string: return " = \"\(constant)\""
        case .valueEnum: return " = .\(ValueEnumEmitter.reference(for: constant))"
        default: return ""
        }
    }

    static func swiftType(of field: ApiField) -> String {
        field.type.swiftTypeName + (field.isOptional ? "?" : "")
    }

    private static func boxedType(of field: ApiField) -> String {
        "_IndirectBox<\(field.type.swiftTypeName)>" + (field.isOptional ? "?" : "")
    }
}
