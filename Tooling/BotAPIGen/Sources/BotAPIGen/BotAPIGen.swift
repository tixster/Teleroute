import Foundation

/// Generates Teleroute's Telegram Bot API layers from a committed snapshot of
/// the official documentation.
///
///     swift run BotAPIGen --snapshot botapi \
///                         --types-output Sources/TelegramBotAPI/Generated \
///                         --client-output Sources/TelegramBotKit/Generated
///
/// The default run is offline and deterministic: it reads the committed HTML,
/// checks it against `snapshot.json`, and writes the same bytes every time.
/// Only `--refresh-snapshot` rewrites the snapshot metadata, and only
/// `Scripts/generate-api.sh --refresh` ever touches the network.
@main
struct BotAPIGen {
    static func main() {
        do {
            try self.run(arguments: Array(CommandLine.arguments.dropFirst()))
        } catch {
            FileHandle.standardError.write(Data("BotAPIGen: \(error)\n".utf8))
            exit(1)
        }
    }

    static func run(arguments: [String]) throws {
        var options = Options()
        var index = arguments.startIndex
        while index < arguments.endIndex {
            let argument = arguments[index]
            func value() throws -> String {
                index += 1
                guard index < arguments.endIndex else {
                    throw GeneratorError("\(argument) requires a value")
                }
                return arguments[index]
            }
            switch argument {
            case "--snapshot": options.snapshot = try value()
            case "--types-output": options.typesOutput = try value()
            case "--client-output": options.clientOutput = try value()
            case "--dump-ir": options.dumpIR = try value()
            case "--refresh-snapshot": options.refreshSnapshot = true
            case "--help", "-h": print(Self.usage); return
            default: throw GeneratorError("unknown argument '\(argument)'")
            }
            index += 1
        }
        guard let snapshotDirectory = options.snapshot else {
            throw GeneratorError("--snapshot is required\n\n\(Self.usage)")
        }

        let snapshot = try Snapshot.load(
            directory: URL(fileURLWithPath: snapshotDirectory),
            refreshing: options.refreshSnapshot
        )
        let parser = SpecParser(html: snapshot.html, sha256: snapshot.sha256)
        let (spec, statistics) = try parser.parse()
        try snapshot.verify(botApiVersion: spec.botApiVersion, botApiDate: spec.botApiDate)
        try Invariants.check(spec: spec, statistics: statistics)

        if let dumpIR = options.dumpIR {
            try IRDump.write(spec: spec, to: URL(fileURLWithPath: dumpIR))
        }

        var written = 0
        if let typesOutput = options.typesOutput {
            written += try TypeEmitter(spec: spec).write(to: URL(fileURLWithPath: typesOutput))
        }
        if let clientOutput = options.clientOutput {
            written += try MethodEmitter(spec: spec).write(to: URL(fileURLWithPath: clientOutput))
        }

        print(
            """
            BotAPIGen: Bot API \(spec.botApiVersion) (\(spec.botApiDate))
              types   \(spec.types.count)
              methods \(spec.methods.count)
              files   \(written)
            """
        )
    }

    struct Options {
        var snapshot: String?
        var typesOutput: String?
        var clientOutput: String?
        var dumpIR: String?
        var refreshSnapshot = false
    }

    static let usage = """
        usage: swift run BotAPIGen --snapshot <dir> [options]

          --snapshot <dir>         directory holding telegram-bot-api.html and snapshot.json
          --types-output <dir>     write the generated model layer here
          --client-output <dir>    write the generated client layer here
          --dump-ir <file>         write the parsed documentation as JSON, for cross-checking
          --refresh-snapshot       rewrite snapshot.json from the HTML on disk
        """
}
