import Foundation

/// Accumulates generated Swift with an indent level.
struct SwiftPrinter {
    private(set) var lines: [String] = []
    private var indent = 0

    var indentation: String { String(repeating: "    ", count: self.indent) }

    mutating func line(_ text: String = "") {
        self.lines.append(text.isEmpty ? "" : self.indentation + text)
    }

    mutating func raw(_ lines: [String]) {
        self.lines.append(contentsOf: lines)
    }

    mutating func doc(_ markdown: String) {
        guard !markdown.isEmpty else { return }
        self.raw(InlineText.docComment(markdown, indent: self.indentation))
    }

    /// Runs `body` one indent level deeper. Used where a declaration's header
    /// spans several lines and `block` cannot express it.
    mutating func indenting(_ body: (inout SwiftPrinter) -> Void) {
        self.indent += 1
        body(&self)
        self.indent -= 1
    }

    /// A `switch` whose cases sit at the same indentation as the `switch`
    /// itself, the way Swift is conventionally written.
    mutating func switchBlock(_ header: String, _ body: (inout SwiftPrinter) -> Void) {
        self.line(header + " {")
        body(&self)
        self.line("}")
    }

    mutating func block(_ header: String, _ body: (inout SwiftPrinter) -> Void) {
        self.line(header + " {")
        self.indent += 1
        body(&self)
        self.indent -= 1
        self.line("}")
    }

    var text: String { self.lines.joined(separator: "\n") + "\n" }
}

enum GeneratedFile {
    /// The banner every generated file carries.
    ///
    /// It names the Bot API revision the sources were produced from, so a file
    /// on disk always says which version of the documentation it matches.
    static func header(spec: ApiSpec) -> [String] {
        [
            "// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.",
            "// Bot API \(spec.botApiVersion) (\(spec.botApiDate)).",
            "//",
            "// Do not edit by hand: re-run Scripts/generate-api.sh instead.",
            "",
        ]
    }

    /// Writes `contents` to `directory/path`, creating intermediate folders.
    ///
    /// `path` may name a subfolder (`AvailableTypes/Message.swift`).
    static func write(_ contents: String, named path: String, in directory: URL) throws {
        let url = directory.appendingPathComponent(path)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        try Data(contents.utf8).write(to: url)
    }

    /// Removes every generated file this run did not produce, then any folder
    /// left empty.
    ///
    /// With one file per type, a renamed or withdrawn type would otherwise
    /// leave a stale file behind that still compiles — which is exactly the
    /// kind of thing nobody notices until it contradicts the documentation.
    static func prune(directory: URL, keeping written: Set<String>) throws {
        let manager = FileManager.default
        guard let walker = manager.enumerator(atPath: directory.path) else { return }
        var directories: [String] = []
        for case let entry as String in walker {
            let url = directory.appendingPathComponent(entry)
            var isDirectory: ObjCBool = false
            guard manager.fileExists(atPath: url.path, isDirectory: &isDirectory) else { continue }
            if isDirectory.boolValue {
                directories.append(entry)
            } else if entry.hasSuffix(".swift"), !written.contains(entry) {
                try manager.removeItem(at: url)
            }
        }
        // Deepest first, so a folder emptied by the pass above also goes.
        for entry in directories.sorted(by: { $0.count > $1.count }) {
            let url = directory.appendingPathComponent(entry)
            let remaining = (try? manager.contentsOfDirectory(atPath: url.path)) ?? []
            if remaining.isEmpty { try manager.removeItem(at: url) }
        }
    }
}
