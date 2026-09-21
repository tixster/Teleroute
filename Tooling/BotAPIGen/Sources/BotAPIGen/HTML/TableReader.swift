/// One `<table class="table">` reduced to its header labels and raw cell HTML.
struct RawTable {
    /// `<th>` labels, e.g. `["Field", "Type", "Description"]`.
    var headers: [String]
    /// `<tbody>` rows; cells keep their inline HTML so descriptions survive.
    var rows: [[String]]
}

enum TableReader {
    private static let tableOpen = "<table class=\"table\">"

    /// The first table in an entry, or `nil` when the entry has none.
    ///
    /// "First" is unambiguous: the parser asserts elsewhere that no `<h4>`
    /// section of the page contains more than one table.
    static func firstTable(in content: String) throws -> RawTable? {
        guard let open = content.range(of: self.tableOpen) else { return nil }
        guard let close = content.range(of: "</table>", range: open.upperBound..<content.endIndex) else {
            throw GeneratorError("unterminated <table class=\"table\"> in the documentation snapshot")
        }
        let table = String(content[open.upperBound..<close.lowerBound])

        let headers = try HTMLScanner.slices(of: table, between: "<th>", and: "</th>")
            .map { try HTMLScanner.plainText(String($0)) }

        guard let bodyStart = table.range(of: "<tbody>"),
              let bodyEnd = table.range(of: "</tbody>", range: bodyStart.upperBound..<table.endIndex)
        else {
            throw GeneratorError("table without a <tbody> in the documentation snapshot")
        }
        let tbody = String(table[bodyStart.upperBound..<bodyEnd.lowerBound])

        let rows = HTMLScanner.slices(of: tbody, between: "<tr>", and: "</tr>").map { row in
            HTMLScanner.slices(of: String(row), between: "<td>", and: "</td>").map(String.init)
        }
        return RawTable(headers: headers, rows: rows)
    }

    /// The number of `<table class="table">` elements in an entry. Used by the
    /// invariant that the "first table" rule is safe.
    static func tableCount(in content: String) -> Int {
        content.components(separatedBy: self.tableOpen).count - 1
    }

    /// Link targets of a `<ul><li><a href="#x">Name</a></li></ul>` list — the
    /// shape Telegram uses to enumerate a union's variants.
    static func linkList(in content: String) throws -> [String] {
        guard let open = content.range(of: "<ul>"),
              let close = content.range(of: "</ul>", range: open.upperBound..<content.endIndex)
        else { return [] }
        let list = String(content[open.upperBound..<close.lowerBound])
        var names: [String] = []
        for item in HTMLScanner.slices(of: list, between: "<li>", and: "</li>") {
            let text = try HTMLScanner.plainText(String(item))
            // Only single-word, capitalised entries are type links; the page
            // also uses <ul> for prose bullet lists.
            guard !text.isEmpty, text.first!.isUppercase, !text.contains(" ") else { return [] }
            names.append(text)
        }
        return names
    }

    /// The `<p>` paragraphs preceding the first table, as raw HTML.
    static func leadingParagraphs(in content: String) -> [String] {
        let head: String
        if let table = content.range(of: self.tableOpen) {
            head = String(content[content.startIndex..<table.lowerBound])
        } else {
            head = content
        }
        return HTMLScanner.slices(of: head, between: "<p>", and: "</p>").map(String.init)
    }
}
