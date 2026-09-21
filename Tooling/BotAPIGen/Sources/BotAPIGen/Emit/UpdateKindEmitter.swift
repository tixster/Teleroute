import Foundation

/// Emits `UpdateKind`, derived from the fields of the `Update` type.
///
/// The raw values are the wire strings `getUpdates`/`setWebhook` accept in
/// `allowed_updates`, so the enum stays in step with the documentation rather
/// than with a hand-maintained list.
struct UpdateKindEmitter {
    let spec: ApiSpec

    func render() -> String {
        var printer = SwiftPrinter()
        printer.raw(GeneratedFile.header(spec: self.spec))
        printer.line("import TelegramBotAPI")
        printer.line()

        let kinds = (self.spec.typesByName["Update"]?.fields ?? [])
            .filter { $0.wireName != "update_id" }

        printer.doc(
            "A kind of incoming Telegram update; raw values are the wire strings accepted by "
                + "`allowed_updates`."
        )
        printer.block("public enum UpdateKind: String, CaseIterable, Sendable, Hashable") { printer in
            for kind in kinds {
                printer.line("case \(kind.swiftName) = \"\(kind.wireName)\"")
            }
        }
        printer.line()
        printer.block("public extension Update") { printer in
            printer.doc("The kind of this update, when it carries a known payload.")
            printer.block("var kind: UpdateKind?") { printer in
                for kind in kinds {
                    printer.line("if self.\(kind.swiftName) != nil { return .\(kind.swiftName) }")
                }
                printer.line("return nil")
            }
        }
        return printer.text
    }
}
