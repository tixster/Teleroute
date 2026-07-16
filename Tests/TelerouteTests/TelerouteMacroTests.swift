import Testing
@testable import Teleroute
import TelerouteMacros
import TelerouteTestSupport
import SwiftTelegramBot

@Suite(.serialized)
struct TelerouteMacroTests {
    @Test func commandMacroSynthesizesPathAndInit() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let router = Teleroute(bot: bot, logger: .init(label: "router.macro.command"))
        let recorder = TelerouteTestRecorder<[String]>()

        router.command(MacroBanCommand.self) { command, _ in
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

    @Test func commandMacroPreservesOptionalTypeInMemberwiseInitializer() {
        let command = MacroBanCommand(userID: "42", reason: nil)
        #expect(command.userID == "42")
        #expect(command.reason == nil)
    }

    @Test func callbackMacroSynthesizesPathAndRoundTrips() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let router = Teleroute(bot: bot, logger: .init(label: "router.macro.callback"))
        let recorder = TelerouteTestRecorder<String>()

        router.callback(MacroApproveCallback.self) { callback, _ in
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
        let encoded = decoded.parameters
        #expect(encoded["orderID"] == "42")
    }

    @Test func macrosSupportHandlingTypedRoutesWithoutRegistrationClosures() async throws {
        await MacroHandlingCommand.recorder.reset()
        await MacroHandlingCallback.recorder.reset()

        let bot = try await TelerouteTestSupport.makeBot()
        let router = Teleroute(
            bot: bot,
            logger: .init(label: "router.macro.self-handling"),
            configuration: .init(replayProtectionStorage: nil)
        )

        router.command(MacroHandlingCommand.self)
        router.callback(MacroHandlingCallback.self)

        await router.handle()
        await router.process([
            TelerouteTestSupport.makeCommandUpdate(text: "/remember hello", updateId: 802),
            TelerouteTestSupport.makeCallbackUpdate(data: "remember/42", updateId: 803),
        ])

        #expect(
            await MacroHandlingCommand.recorder.waitForCount(1, retries: 100)
                == ["hello"]
        )
        #expect(
            await MacroHandlingCallback.recorder.waitForCount(1, retries: 100)
                == ["42"]
        )
        router.shutdown()
    }
}

// MARK: - Fixtures (use the macros)

@TelerouteCommand("ban")
struct MacroBanCommand {
    let userID: String
    let reason: String?
}

@TelerouteCallback("orders/{orderID}/approve")
struct MacroApproveCallback {
    let orderID: String
}

@TelerouteCommand("remember")
struct MacroHandlingCommand: TelerouteHandlingCommand {
    static let recorder = TelerouteTestRecorder<String>()

    let value: String

    func handle(context: TelerouteContext) async throws {
        await Self.recorder.record(self.value)
    }
}

@TelerouteCallback("remember/{value}")
struct MacroHandlingCallback: TelerouteHandlingCallback {
    static let recorder = TelerouteTestRecorder<String>()

    let value: String

    func handle(context: TelerouteContext) async throws {
        await Self.recorder.record(self.value)
    }
}
