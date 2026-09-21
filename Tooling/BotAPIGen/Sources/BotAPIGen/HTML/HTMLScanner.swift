/// Low-level helpers over the raw documentation HTML.
///
/// The Bot API page is flat enough that none of this needs a DOM: every
/// construct the parser reads (`<h3>`, `<h4>`, `<p>`, `<table class="table">`,
/// `<ul><li>`) sits at one nesting level under `#dev_page_content`, and no
/// section contains more than one table. A linear scanner is both simpler and
/// dependency-free, which is what keeps generation offline and reproducible.
enum HTMLScanner {
    /// Named entities the documentation actually uses.
    ///
    /// Anything outside this table is a hard failure rather than a silent
    /// pass-through: an unrecognized entity means the page grew a construct we
    /// have not looked at, and a human should look at it.
    private static let namedEntities: [String: String] = [
        "amp": "&", "lt": "<", "gt": ">", "quot": "\"", "apos": "'",
        "nbsp": "\u{00A0}", "hellip": "\u{2026}", "mdash": "\u{2014}",
        "ndash": "\u{2013}", "laquo": "\u{00AB}", "raquo": "\u{00BB}",
        "ldquo": "\u{201C}", "rdquo": "\u{201D}", "lsquo": "\u{2018}",
        "rsquo": "\u{2019}", "times": "\u{00D7}", "rarr": "\u{2192}",
        "copy": "\u{00A9}", "reg": "\u{00AE}", "deg": "\u{00B0}",
    ]

    /// Decodes numeric and named HTML entities, throwing on anything unknown.
    static func decodeEntities(_ input: String) throws -> String {
        guard input.contains("&") else { return input }
        var out = ""
        out.reserveCapacity(input.count)
        var index = input.startIndex
        while let amp = input[index...].firstIndex(of: "&") {
            out += input[index..<amp]
            guard let semi = input[amp...].firstIndex(of: ";"),
                  case let name = String(input[input.index(after: amp)..<semi]),
                  Self.looksLikeEntityName(name)
            else {
                // A bare ampersand in prose. The page has a few; keep it.
                out.append("&")
                index = input.index(after: amp)
                continue
            }
            out += try self.expand(entity: name)
            index = input.index(after: semi)
        }
        out += input[index...]
        return out
    }

    /// An entity name is a short run of letters and digits, optionally a `#`
    /// followed by a number. Anything else — notably anything containing a
    /// space — is prose that happens to have an ampersand in it.
    private static func looksLikeEntityName(_ name: String) -> Bool {
        guard !name.isEmpty, name.count <= 10 else { return false }
        let body = name.hasPrefix("#") ? name.dropFirst() : name[...]
        guard !body.isEmpty else { return false }
        if name.hasPrefix("#") {
            let digits = body.hasPrefix("x") || body.hasPrefix("X") ? body.dropFirst() : body
            return !digits.isEmpty && digits.allSatisfy(\.isHexDigit)
        }
        return body.allSatisfy { $0.isLetter || $0.isNumber }
    }

    private static func expand(entity name: String) throws -> String {
        if name.hasPrefix("#") {
            let digits = name.dropFirst()
            let scalarValue: UInt32?
            if digits.hasPrefix("x") || digits.hasPrefix("X") {
                scalarValue = UInt32(digits.dropFirst(), radix: 16)
            } else {
                scalarValue = UInt32(digits, radix: 10)
            }
            guard let scalarValue, let scalar = Unicode.Scalar(scalarValue) else {
                throw GeneratorError("unrecognized numeric HTML entity '&\(name);'")
            }
            return String(Character(scalar))
        }
        guard let replacement = self.namedEntities[name] else {
            throw GeneratorError(
                "unrecognized HTML entity '&\(name);' — the documentation grew a "
                    + "construct the scanner has not seen; add it to HTMLScanner.namedEntities"
            )
        }
        return replacement
    }

    /// Removes every tag, leaving only text. Entities are left alone.
    static func stripTags(_ input: String) -> String {
        guard input.contains("<") else { return input }
        var out = ""
        out.reserveCapacity(input.count)
        var depth = 0
        for character in input {
            switch character {
            case "<": depth += 1
            case ">": if depth > 0 { depth -= 1 }
            default: if depth == 0 { out.append(character) }
            }
        }
        return out
    }

    /// Tags stripped, entities decoded, whitespace collapsed and trimmed.
    static func plainText(_ input: String) throws -> String {
        try self.collapseWhitespace(self.decodeEntities(self.stripTags(input)))
    }

    static func collapseWhitespace(_ input: String) -> String {
        var out = ""
        out.reserveCapacity(input.count)
        var pendingSpace = false
        for character in input {
            if character.isWhitespace || character == "\u{00A0}" {
                pendingSpace = !out.isEmpty
            } else {
                if pendingSpace { out.append(" ") }
                pendingSpace = false
                out.append(character)
            }
        }
        return out
    }

    /// All non-overlapping slices between `open` and `close`, in document order.
    static func slices(of input: String, between open: String, and close: String) -> [Substring] {
        var results: [Substring] = []
        var cursor = input.startIndex
        while let start = input.range(of: open, range: cursor..<input.endIndex) {
            guard let end = input.range(of: close, range: start.upperBound..<input.endIndex) else { break }
            results.append(input[start.upperBound..<end.lowerBound])
            cursor = end.upperBound
        }
        return results
    }
}

/// A generation failure. Every message names the construct and, where there is
/// one, the expected shape — drift in the documentation must fail loudly rather
/// than silently degrade the emitted API.
struct GeneratorError: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
}
