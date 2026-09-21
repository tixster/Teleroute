/// Converts the documentation's inline HTML into DocC-flavoured markdown for
/// generated doc comments.
struct InlineText {
    /// Type names that exist as generated symbols, so a doc anchor pointing at
    /// one can become a real DocC link.
    let knownTypes: Set<String>

    /// Renders an HTML fragment as markdown.
    func markdown(_ html: String) throws -> String {
        HTMLScanner.collapseWhitespace(try self.render(html[...]))
    }

    private func render(_ html: Substring) throws -> String {
        var out = ""
        var index = html.startIndex
        while let open = html[index...].firstIndex(of: "<") {
            out += try HTMLScanner.decodeEntities(String(html[index..<open]))
            guard let tagEnd = html[open...].firstIndex(of: ">") else {
                out += try HTMLScanner.decodeEntities(String(html[open...]))
                return out
            }
            let raw = html[html.index(after: open)..<tagEnd]
            let isClosing = raw.hasPrefix("/")
            let name = raw.drop(while: { $0 == "/" })
                .prefix(while: { !$0.isWhitespace && $0 != "/" })
                .lowercased()
            index = html.index(after: tagEnd)

            switch (name, isClosing) {
            case ("a", false):
                let href = Self.attribute("href", in: raw) ?? ""
                guard let closeRange = Self.matchingAnchorClose(in: html, from: index) else {
                    throw GeneratorError(
                        "unterminated <a> in a documentation fragment: \(html.prefix(160))"
                    )
                }
                let inner = try self.render(html[index..<closeRange.lowerBound])
                out += self.link(href: href, text: inner)
                index = closeRange.upperBound
            case ("em", _):
                out += "*"
            case ("strong", _), ("b", _):
                out += "**"
            case ("code", _):
                out += "`"
            case ("br", _):
                out += "\n"
            case ("img", false):
                // Telegram renders emoji as images, so the character itself
                // lives in `alt`. Dropping the tag would silently empty out
                // lists like ReactionTypeEmoji's.
                out += Self.attribute("alt", in: raw) ?? ""
            default:
                // <span>, <blockquote>, </a> consumed above, and <i>, which
                // this page uses only for the anchor-icon markers.
                break
            }
        }
        out += try HTMLScanner.decodeEntities(String(html[index...]))
        return out
    }

    /// Chooses the markdown form for one anchor.
    ///
    /// A doc anchor naming a generated type becomes a DocC symbol link. Method
    /// anchors become code spans instead: methods live in `TelegramBotKit`, so
    /// a symbol link from `TelegramBotAPI` would dangle. Prose anchors
    /// (`#sending-files`, `#formatting-options`) have no symbol at all.
    private func link(href: String, text: String) -> String {
        if href.hasPrefix("#") {
            if self.knownTypes.contains(text) { return "``\(text)``" }
            if let first = text.first, first.isLowercase, !text.contains(" ") { return "`\(text)`" }
            return text
        }
        if href.hasPrefix("http") {
            // Telegram sometimes nests an anchor inside an identical one; the
            // inner render is already a complete markdown link.
            if text.hasPrefix("["), text.hasSuffix(")") { return text }
            return "[\(text)](\(href))"
        }
        return text
    }

    /// The `</a>` that closes the anchor starting at `start`, counting nested
    /// opens.
    ///
    /// The page really does nest anchors — `RichBlockThinking`'s description
    /// contains `<a href="X"><a href="X">X</a></a>` — so taking the first
    /// `</a>` would cut an anchor in half.
    private static func matchingAnchorClose(
        in html: Substring,
        from start: Substring.Index
    ) -> Range<Substring.Index>? {
        var depth = 1
        var cursor = start
        while cursor < html.endIndex {
            guard let next = html[cursor...].firstIndex(of: "<") else { return nil }
            guard let tagEnd = html[next...].firstIndex(of: ">") else { return nil }
            let raw = html[html.index(after: next)..<tagEnd]
            if raw.hasPrefix("/a") && !raw.dropFirst(2).hasPrefix("b") {
                depth -= 1
                if depth == 0 { return next..<html.index(after: tagEnd) }
            } else if raw == "a" || raw.hasPrefix("a ") {
                depth += 1
            }
            cursor = html.index(after: tagEnd)
        }
        return nil
    }

    private static func attribute(_ name: String, in tag: Substring) -> String? {
        guard let key = tag.range(of: "\(name)=\"") else { return nil }
        guard let end = tag[key.upperBound...].firstIndex(of: "\"") else { return nil }
        return String(tag[key.upperBound..<end])
    }
}

extension InlineText {
    /// Wraps markdown into `///` doc-comment lines at `width` columns.
    ///
    /// Leading `-` and `#` are escaped so DocC does not read a wrapped line as
    /// a list item or a heading.
    static func docComment(_ markdown: String, indent: String, width: Int = 96) -> [String] {
        let budget = max(width - indent.count - 4, 40)
        var lines: [String] = []
        for paragraph in markdown.components(separatedBy: "\n") {
            let words = paragraph.split(separator: " ", omittingEmptySubsequences: true)
            if words.isEmpty {
                lines.append("")
                continue
            }
            var current = ""
            for word in words {
                if current.isEmpty {
                    current = String(word)
                } else if current.count + 1 + word.count <= budget {
                    current += " " + word
                } else {
                    lines.append(current)
                    current = String(word)
                }
            }
            if !current.isEmpty { lines.append(current) }
        }
        return lines.map { line in
            let escaped = line.hasPrefix("-") || line.hasPrefix("#") ? "\\" + line : line
            return escaped.isEmpty ? "\(indent)///" : "\(indent)/// \(escaped)"
        }
    }
}
