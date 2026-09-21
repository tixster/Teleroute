/// The documentation page sliced into its `<h3>` sections and `<h4>` entries.
struct SlicedDocument {
    /// Every `<h3>` title, in document order.
    var sectionTitles: [String]
    /// Every `<h4>` entry, in document order, tagged with its enclosing `<h3>`.
    var entries: [RawEntry]
}

/// One `<h4>` block: a type, a method, or a prose aside.
struct RawEntry {
    /// The enclosing `<h3>` title, e.g. `Available types`.
    var section: String
    /// The `<h4>` text with tags stripped, e.g. `Update` or `sendMessage`.
    var title: String
    /// Raw HTML from the end of the `<h4>` to the start of the next heading.
    var content: String
}

enum DocumentSlicer {
    private static let contentMarker = "id=\"dev_page_content\""

    /// Splits the page body into `<h3>` sections and `<h4>` entries.
    static func slice(_ html: String) throws -> SlicedDocument {
        guard let marker = html.range(of: self.contentMarker) else {
            throw GeneratorError(
                "documentation snapshot has no '\(self.contentMarker)' element — "
                    + "the page layout changed"
            )
        }
        let body = html[marker.upperBound...]

        var headings: [(level: Int, start: String.Index, titleRange: Range<String.Index>, contentStart: String.Index)] = []
        var cursor = body.startIndex
        while cursor < body.endIndex {
            guard let open = body.range(of: "<h", range: cursor..<body.endIndex) else { break }
            let levelIndex = open.upperBound
            guard levelIndex < body.endIndex,
                  let level = body[levelIndex].wholeNumberValue,
                  level == 3 || level == 4,
                  body.index(after: levelIndex) < body.endIndex,
                  body[body.index(after: levelIndex)] == ">"
            else {
                cursor = open.upperBound
                continue
            }
            let titleStart = body.index(levelIndex, offsetBy: 2)
            guard let close = body.range(of: "</h\(level)>", range: titleStart..<body.endIndex) else {
                throw GeneratorError("unterminated <h\(level)> in the documentation snapshot")
            }
            headings.append((level, open.lowerBound, titleStart..<close.lowerBound, close.upperBound))
            cursor = close.upperBound
        }

        var sectionTitles: [String] = []
        var entries: [RawEntry] = []
        var currentSection = ""
        for (offset, heading) in headings.enumerated() {
            let title = try HTMLScanner.plainText(String(body[heading.titleRange]))
            let contentEnd = offset + 1 < headings.count ? headings[offset + 1].start : body.endIndex
            if heading.level == 3 {
                sectionTitles.append(title)
                currentSection = title
            } else {
                entries.append(
                    RawEntry(
                        section: currentSection,
                        title: title,
                        content: String(body[heading.contentStart..<contentEnd])
                    )
                )
            }
        }
        return SlicedDocument(sectionTitles: sectionTitles, entries: entries)
    }
}
