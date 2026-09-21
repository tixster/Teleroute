import Foundation

/// Parses the documentation's Type column into the IR's `FieldType`.
///
/// The grammar the page actually uses is tiny:
///
///     type      ::= "Array of " type | irregular | orChain | primitive | Name
///     irregular ::= "Array of " Name ("," Name)* " and " Name
///     orChain   ::= Name (" or " Name)+
///     primitive ::= String | Integer | Boolean | Float | True
///
/// Anything outside it is a hard failure. A silently-unparsed type string would
/// become a silently-wrong Swift signature, which is the failure mode this
/// whole generator is built to avoid.
struct TypeGrammar {
    let knownTypes: Set<String>
    /// Variant set → union name, covering both documented unions and the two
    /// synthesized ones in `KnownDeviations`.
    let unionsByVariants: [Set<String>: String]
    /// Union names that were resolved from an inline `or` chain, for the
    /// invariant that exactly two synthesized unions exist.
    private(set) var resolvedInlineUnions: [String: Int] = [:]

    init(knownTypes: Set<String>, unionsByVariants: [Set<String>: String]) {
        self.knownTypes = knownTypes
        self.unionsByVariants = unionsByVariants
    }

    mutating func parse(_ text: String, context: @autoclosure () -> String) throws -> FieldType {
        let trimmed = text.trimmingCharacters(in: .whitespaces)

        if let rest = trimmed.dropPrefixIfPresent("Array of ") {
            return .array(try self.parse(String(rest), context: context()))
        }
        if trimmed.contains(" or ") {
            return try self.resolveUnion(
                Self.splitNames(trimmed, separator: " or "),
                spelling: trimmed,
                context: context()
            )
        }
        if trimmed.contains(" and ") {
            return try self.resolveUnion(
                Self.splitIrregular(trimmed),
                spelling: trimmed,
                context: context()
            )
        }
        switch trimmed {
        case "String": return .string
        case "Integer": return .integer
        case "Boolean": return .boolean
        case "Float", "Float number": return .float
        case "True": return .trueLiteral
        case "InputFile": return .fileOrString
        default: break
        }
        guard self.knownTypes.contains(trimmed) else {
            throw GeneratorError(
                "unparsed type string '\(trimmed)' at \(context()) — it names no documented "
                    + "type and matches no production of the type grammar"
            )
        }
        return .named(trimmed)
    }

    private mutating func resolveUnion(
        _ names: [String],
        spelling: String,
        context: String
    ) throws -> FieldType {
        let set = Set(names)
        if set == ["Integer", "String"] { return .chatId }
        if set == ["InputFile", "String"] { return .fileOrString }
        guard let union = self.unionsByVariants[set] else {
            throw GeneratorError(
                "unresolved union '\(spelling)' at \(context) — its variant set matches no "
                    + "documented union and no entry in KnownDeviations.synthesizedUnions"
            )
        }
        self.resolvedInlineUnions[union, default: 0] += 1
        return .named(union)
    }

    /// `"A or B or C"` → `["A", "B", "C"]`.
    private static func splitNames(_ text: String, separator: String) -> [String] {
        text.components(separatedBy: separator).map { $0.trimmingCharacters(in: .whitespaces) }
    }

    /// `"A, B, C and D"` → `["A", "B", "C", "D"]`. One site uses this form.
    private static func splitIrregular(_ text: String) -> [String] {
        text
            .replacingOccurrences(of: " and ", with: ", ")
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}

extension StringProtocol {
    func dropPrefixIfPresent(_ prefix: String) -> SubSequence? {
        self.hasPrefix(prefix) ? self.dropFirst(prefix.count) : nil
    }
}
