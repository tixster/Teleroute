import Foundation

/// Recovers each method's return type from its prose.
///
/// Telegram documents return types only in sentences ("On success, the sent
/// Message is returned"), so this is the one place the generator reads English.
/// It is made safe by two rules: the patterns are tried in a fixed order, and a
/// match only counts when the name it captured is a type the page actually
/// documents. That second rule is what keeps `getWebhookInfo`'s trailing "will
/// return an object with the url field empty" from winning, and it lets the
/// later patterns be greedy without becoming reckless.
struct ReturnGrammar {
    let knownTypes: Set<String>

    private enum Outcome {
        case messageOrBool
        case array
        case single
        case trueValue
    }

    private static let name = "([A-Z][A-Za-z0-9]*)"

    private static let patterns: [(source: String, outcome: Outcome)] = [
        ("Message is returned, otherwise True[^.]*is returned", .messageOrBool),
        ("[Aa]n Array of \(name)[^.]{0,40}? is returned", .array),
        ("Returns an Array of \(name)", .array),
        ("in form of an? \(name) object", .single),
        ("Returns [a-z][^.]{0,60}? as (?:an? )?\(name)(?: object)?", .single),
        ("Returns the (?:uploaded|stopped|sent|created|edited|new|revoked) \(name)", .single),
        ("Returns the \(name) of the sent message", .single),
        ("the (?:sent|edited|stopped) \(name) is returned", .single),
        ("[Rr]eturns an? \(name) object", .single),
        ("an? \(name) object is returned", .single),
        ("Returns \(name) on success", .single),
        ("True is returned", .trueValue),
        ("Returns True on success", .trueValue),
    ]

    /// Resolves one method's return type, or throws naming the method.
    func parse(description: String, method: String) throws -> ReturnType {
        for (source, outcome) in Self.patterns {
            guard let regex = try? NSRegularExpression(pattern: source) else {
                throw GeneratorError("malformed return-type pattern '\(source)'")
            }
            let range = NSRange(description.startIndex..., in: description)
            for match in regex.matches(in: description, range: range) {
                switch outcome {
                case .messageOrBool:
                    return .messageOrBool
                case .trueValue:
                    return .value(.boolean)
                case .array, .single:
                    guard match.numberOfRanges > 1,
                          let captured = Range(match.range(at: 1), in: description)
                    else { continue }
                    let name = String(description[captured])
                    guard let element = self.resolve(name) else { continue }
                    return .value(outcome == .array ? .array(element) : element)
                }
            }
        }
        throw GeneratorError(
            "no return type resolved for '\(method)' — none of the "
                + "\(Self.patterns.count) documented phrasings matched its description"
        )
    }

    private func resolve(_ name: String) -> FieldType? {
        switch name {
        case "String": .string
        case "Integer": .integer
        case "True", "Boolean": .boolean
        case "Float": .float
        default: self.knownTypes.contains(name) ? .named(name) : nil
        }
    }
}
