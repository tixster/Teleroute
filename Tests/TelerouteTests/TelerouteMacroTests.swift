import Testing
@testable import Teleroute
import TelerouteTestSupport
import SwiftTelegramBot

@Suite(.serialized)
struct TelerouteMacroTests {
    @Test func commandMacroSynthesizesPathAndInit() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let router = Teleroute(bot: bot, logger: .init(label: "router.macro.command"))
        let recorder = TelerouteTestRecorder<[String]>()

        router.command(MacroBanCommand.self) { _, _, command in
            await recorder.record([command.userID, command.reason ?? "none"])
        }

        await router.handle()
        await router.process([
            TelerouteTestSupport.makeCommandUpdate(text: "/ban 42 spammer", chatId: 200, updateId: 800),
        ])

        let values = await recorder.waitForCount(1, retries: 100)
        #expect(values == [["42", "spammer"]])
        #expect(MacroBanCommand.path == "ban")
    }

    @Test func commandMacroDecodesPositionalArgumentWhenNamedMissing() async throws {
        // The command extractor fills `arguments` positionally; `require(_:at:)`
        // falls back to the index when the named slot is absent.
        let match = TelerouteCommandMatch(
            name: "ban",
            rawValue: "/ban",
            mentionedBotUsername: nil,
            argumentsText: "99 no-reason",
            arguments: ["99", "no-reason"]
        )
        let command = try MacroBanCommand(command: match)
        #expect(command.userID == "99")
        #expect(command.reason == "no-reason")
    }

    @Test func callbackMacroSynthesizesPathAndRoundTrips() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let router = Teleroute(bot: bot, logger: .init(label: "router.macro.callback"))
        let recorder = TelerouteTestRecorder<String>()

        router.callback(MacroApproveCallback.self) { _, _, callback in
            await recorder.record("approved:\(callback.orderID)")
        }

        await router.handle()
        await router.process([
            TelerouteTestSupport.makeCallbackUpdate(data: "orders/77/approve", chatId: 201, updateId: 801),
        ])

        let values = await recorder.waitForCount(1, retries: 100)
        #expect(values == ["approved:77"])
        #expect(MacroApproveCallback.path == "orders/{orderID}/approve")
    }

    @Test func callbackMacroParametersRoundTrip() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let router = Teleroute(bot: bot, logger: .init(label: "router.macro.callback-rt"))

        let original = MacroApproveCallback(orderID: "42")
        let data = try router.callbackData(for: original)
        #expect(data == "orders/42/approve")

        // Decode via the synthesized init, then re-encode.
        let params = TelerouteParameters(["orderID": "42"])
        let decoded = try MacroApproveCallback(parameters: params)
        let encoded = try decoded.parameters
        #expect(encoded["orderID"] == "42")
    }
}

// MARK: - Fixtures (use the macros)

@TelerouteCommand("ban")
struct MacroBanCommand {
    let userID: String
    let reason: String?

    func handle(update: TGUpdate, context: TelerouteContext) async throws {}
}

@TelerouteCallback("orders/{orderID}/approve")
struct MacroApproveCallback {
    let orderID: String

    func handle(update: TGUpdate, context: TelerouteContext) async throws {
        await TelerouteTestRecorder<String>().record("handle:\(self.orderID)")
    }
}
