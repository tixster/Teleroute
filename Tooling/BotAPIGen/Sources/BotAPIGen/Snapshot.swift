import Crypto
import Foundation

/// The committed copy of the documentation, plus the metadata that proves it is
/// the copy the generated sources were produced from.
struct Snapshot {
    static let htmlFileName = "telegram-bot-api.html"
    static let metadataFileName = "snapshot.json"
    static let sourceURL = "https://core.telegram.org/bots/api"

    var directory: URL
    var html: String
    var sha256: String
    var recordedVersion: String?
    var recordedSHA256: String?
    var refreshing: Bool

    static func load(directory: URL, refreshing: Bool) throws -> Snapshot {
        let htmlURL = directory.appendingPathComponent(self.htmlFileName)
        guard let data = FileManager.default.contents(atPath: htmlURL.path) else {
            throw GeneratorError("no documentation snapshot at \(htmlURL.path)")
        }
        guard let html = String(data: data, encoding: .utf8) else {
            throw GeneratorError("\(htmlURL.path) is not valid UTF-8")
        }
        let digest = SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()

        var recordedVersion: String?
        var recordedSHA256: String?
        let metadataURL = directory.appendingPathComponent(self.metadataFileName)
        if let metadata = FileManager.default.contents(atPath: metadataURL.path),
           let object = try JSONSerialization.jsonObject(with: metadata) as? [String: Any] {
            recordedVersion = object["botApiVersion"] as? String
            recordedSHA256 = object["sha256"] as? String
        }
        return Snapshot(
            directory: directory,
            html: html,
            sha256: digest,
            recordedVersion: recordedVersion,
            recordedSHA256: recordedSHA256,
            refreshing: refreshing
        )
    }

    /// Cross-checks the snapshot against its metadata, or rewrites the metadata
    /// when refreshing. A hand-edited HTML file fails here rather than silently
    /// producing sources nothing can reproduce.
    func verify(botApiVersion: String, botApiDate: String) throws {
        guard !self.refreshing else {
            let metadata: [String: String] = [
                "source": Self.sourceURL,
                "sha256": self.sha256,
                "botApiVersion": botApiVersion,
                "botApiDate": botApiDate,
            ]
            let keys = metadata.keys.sorted()
            let body = keys.map { "  \"\($0)\": \"\(metadata[$0]!)\"" }.joined(separator: ",\n")
            try Data("{\n\(body)\n}\n".utf8).write(
                to: self.directory.appendingPathComponent(Self.metadataFileName)
            )
            return
        }
        if let recordedSHA256, recordedSHA256 != self.sha256 {
            throw GeneratorError(
                "\(Self.htmlFileName) does not match \(Self.metadataFileName): recorded "
                    + "\(recordedSHA256), found \(self.sha256). Re-run with --refresh to adopt "
                    + "a new snapshot deliberately."
            )
        }
        if let recordedVersion, recordedVersion != botApiVersion {
            throw GeneratorError(
                "snapshot records Bot API \(recordedVersion) but the HTML documents "
                    + "Bot API \(botApiVersion)"
            )
        }
    }
}
