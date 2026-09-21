import Foundation

/// Emits the enums recovered from field descriptions.
///
/// Each one is a closed set plus an `unknown(String)` escape. Telegram adds
/// values between releases — a new chat type, a new message entity — and an
/// enum that threw on an unrecognised value would turn that into a dropped
/// update rather than a field the caller can inspect.
struct ValueEnumEmitter {
    let spec: ApiSpec

    func render(_ enumeration: ApiValueEnum) -> String {
        var printer = SwiftPrinter()
        printer.raw(GeneratedFile.header(spec: self.spec))

        printer.doc(enumeration.doc)
        if enumeration.users.count > 1 {
            printer.line("///")
            printer.doc("Used by \(enumeration.users.joined(separator: ", ")).")
        }
        printer.block(
            "public enum \(enumeration.name): RawRepresentable, Codable, Hashable, Sendable"
        ) { printer in
            for value in enumeration.values {
                printer.line("case \(Self.caseName(for: value))")
            }
            printer.doc("A value Telegram introduced after these sources were generated.")
            printer.line("case unknown(Swift.String)")

            printer.line()
            printer.block("public var rawValue: Swift.String") { printer in
                printer.switchBlock("switch self") { printer in
                    for value in enumeration.values {
                        printer.line("case .\(Self.reference(for: value)): \"\(value)\"")
                    }
                    printer.line("case let .unknown(value): value")
                }
            }

            printer.line()
            printer.block("public init(rawValue: Swift.String)") { printer in
                printer.switchBlock("switch rawValue") { printer in
                    for value in enumeration.values {
                        printer.line("case \"\(value)\": self = .\(Self.reference(for: value))")
                    }
                    printer.line("default: self = .unknown(rawValue)")
                }
            }

            printer.line()
            printer.block("public init(from decoder: any Decoder) throws") { printer in
                printer.line(
                    "self.init(rawValue: try decoder.singleValueContainer().decode(Swift.String.self))"
                )
            }

            printer.line()
            printer.block("public func encode(to encoder: any Encoder) throws") { printer in
                printer.line("var container = encoder.singleValueContainer()")
                printer.line("try container.encode(self.rawValue)")
            }

            printer.line()
            printer.doc("Every value documented at the time these sources were generated.")
            printer.line(
                "public static let documentedCases: [\(enumeration.name)] = ["
            )
            for value in enumeration.values {
                printer.line("    .\(Self.reference(for: value)),")
            }
            printer.line("]")
        }
        return printer.text
    }

    /// The wire value as a Swift case name, backticked when it collides with a
    /// keyword (`private`, `default`). Values that differ only in case — the
    /// list markers `a`, `A`, `i`, `I` — stay distinct.
    static func caseName(for value: String) -> String {
        let camel = self.reference(for: value)
        return SpecParser.swiftKeywords.contains(camel) ? "`\(camel)`" : camel
    }

    /// The same name as used after a leading dot, where Swift needs no escaping
    /// even for a keyword.
    static func reference(for value: String) -> String {
        let segments = value.split(separator: "_", omittingEmptySubsequences: true)
        guard let first = segments.first else { return value }
        return segments.dropFirst().reduce(String(first)) { partial, segment in
            partial + segment.prefix(1).uppercased() + segment.dropFirst()
        }
    }
}
