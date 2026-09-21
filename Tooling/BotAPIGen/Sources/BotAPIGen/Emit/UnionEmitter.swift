import Foundation

/// Emits a documented union as a Swift enum.
///
/// Where Telegram gives the variants a discriminator — `always “creator”`,
/// `must be *photo*` — the enum decodes by reading that one key, which is both
/// faster and less ambiguous than trying each variant in turn. Where it does
/// not, or where the values are not distinct, the enum falls back to trying
/// each variant in `<ul>` order.
struct UnionEmitter {
    /// The module the model layer is emitted into.
    ///
    /// A union with no discriminator names its cases after the variant types,
    /// so `case Message(Message)` would have the case shadow the struct. Those
    /// payload references are qualified with the module to keep them
    /// unambiguous. Discriminated unions name cases after the wire value and
    /// never need it.
    static let moduleName = "TelegramBotAPI"

    let spec: ApiSpec

    func emit(_ type: ApiType, into printer: inout SwiftPrinter) {
        guard let union = type.union else { return }
        let indirect = self.spec.indirectUnions.contains(type.name) ? "indirect " : ""
        let qualify = self.needsQualification(union)

        printer.doc(type.doc)
        printer.block("public \(indirect)enum \(type.name): Codable, Hashable, Sendable") { printer in
            for alternative in union.extraAlternatives {
                printer.line(
                    "case \(Self.caseName(for: alternative))(\(alternative.swiftTypeName))"
                )
            }
            for variant in union.variants {
                printer.line(
                    "case \(Self.caseName(for: variant, in: union))"
                        + "(\(Self.payloadType(variant, qualified: qualify)))"
                )
            }

            printer.line()
            if let discriminator = union.discriminator {
                self.emitDiscriminated(
                    type, union: union, discriminator: discriminator,
                    qualified: qualify, into: &printer
                )
            } else {
                self.emitTryEachVariant(type, union: union, qualified: qualify, into: &printer)
            }
            printer.line()
            self.emitEncode(union: union, into: &printer)
        }
    }

    // MARK: - Decoding

    private func emitDiscriminated(
        _ type: ApiType,
        union: ApiUnion,
        discriminator: ApiUnion.Discriminator,
        qualified: Bool,
        into printer: inout SwiftPrinter
    ) {
        printer.block("public enum CodingKeys: String, CodingKey") { printer in
            let key = discriminator.wireKey
            let swift = (try? SpecParser.swiftName(for: key, owner: type.name)) ?? key
            printer.line(swift == key ? "case \(swift)" : "case \(swift) = \"\(key)\"")
        }
        printer.line()
        printer.block("public init(from decoder: any Decoder) throws") { printer in
            self.emitExtraAlternativeDecoding(union: union, into: &printer)
            printer.line("let container = try decoder.container(keyedBy: CodingKeys.self)")
            let swift = (try? SpecParser.swiftName(for: discriminator.wireKey, owner: type.name))
                ?? discriminator.wireKey
            printer.switchBlock(
                "switch try container.decode(Swift.String.self, forKey: .\(swift))"
            ) { printer in
                for entry in discriminator.values {
                    printer.line("case \"\(entry.value)\":")
                    printer.line(
                        "    self = .\(Self.caseName(for: entry.variant, in: union))"
                            + "(try \(Self.payloadType(entry.variant, qualified: qualified))"
                            + "(from: decoder))"
                    )
                }
                printer.line("case let other:")
                printer.line("    throw DecodingError.dataCorruptedError(")
                printer.line("        forKey: .\(swift), in: container,")
                printer.line(
                    "        debugDescription: \"unknown \(type.name) \(discriminator.wireKey) "
                        + "'\\(other)'\")"
                )
            }
        }
    }

    private func emitTryEachVariant(
        _ type: ApiType,
        union: ApiUnion,
        qualified: Bool,
        into printer: inout SwiftPrinter
    ) {
        printer.block("public init(from decoder: any Decoder) throws") { printer in
            self.emitExtraAlternativeDecoding(union: union, into: &printer)
            printer.line("var errors: [any Error] = []")
            for variant in union.variants {
                printer.line("do {")
                printer.line(
                    "    self = .\(Self.caseName(for: variant, in: union))"
                        + "(try \(Self.payloadType(variant, qualified: qualified))(from: decoder))"
                )
                printer.line("    return")
                printer.line("} catch {")
                printer.line("    errors.append(error)")
                printer.line("}")
            }
            printer.line("throw DecodingError.typeMismatch(")
            printer.line("    Self.self,")
            printer.line("    DecodingError.Context(")
            printer.line("        codingPath: decoder.codingPath,")
            printer.line(
                "        debugDescription: \"no variant of \(type.name) could decode the payload\","
            )
            printer.line("        underlyingError: errors.first")
            printer.line("    )")
            printer.line(")")
        }
    }

    /// `RichText` is the one union that also accepts a bare string and a nested
    /// array, so those shapes are tried before the keyed variants.
    private func emitExtraAlternativeDecoding(union: ApiUnion, into printer: inout SwiftPrinter) {
        for alternative in union.extraAlternatives {
            printer.block(
                "if let value = try? decoder.singleValueContainer()"
                    + ".decode(\(alternative.swiftTypeName).self)"
            ) { printer in
                printer.line("self = .\(Self.caseName(for: alternative))(value)")
                printer.line("return")
            }
        }
    }

    // MARK: - Encoding

    private func emitEncode(union: ApiUnion, into printer: inout SwiftPrinter) {
        printer.block("public func encode(to encoder: any Encoder) throws") { printer in
            printer.switchBlock("switch self") { printer in
                for alternative in union.extraAlternatives {
                    printer.line("case let .\(Self.caseName(for: alternative))(value):")
                    printer.line("    var container = encoder.singleValueContainer()")
                    printer.line("    try container.encode(value)")
                }
                for variant in union.variants {
                    printer.line("case let .\(Self.caseName(for: variant, in: union))(value):")
                    printer.line("    try value.encode(to: encoder)")
                }
            }
        }
    }

    // MARK: - Case names

    /// A discriminated variant is named after its wire value, so the Swift case
    /// and the JSON agree; anything else keeps the variant's type name.
    static func caseName(for variant: String, in union: ApiUnion) -> String {
        guard let value = union.discriminator?.values.first(where: { $0.variant == variant })?.value
        else { return variant }
        let camel = (try? SpecParser.swiftName(for: value, owner: variant)) ?? value
        return camel
    }

    /// True when any case name would shadow a documented type.
    private func needsQualification(_ union: ApiUnion) -> Bool {
        union.variants.contains { self.spec.typesByName[Self.caseName(for: $0, in: union)] != nil }
    }

    private static func payloadType(_ variant: String, qualified: Bool) -> String {
        qualified ? "\(Self.moduleName).\(variant)" : variant
    }

    /// Names for `RichText`'s two non-struct alternatives.
    static func caseName(for alternative: FieldType) -> String {
        switch alternative {
        case .string: "text"
        case .array: "sequence"
        default: "value"
        }
    }
}
