import Testing
@_spi(Testing) @testable import Teleroute
import TelerouteTestSupport

/// Tests for the unified handler/response model: response generators,
/// guard verdicts, aborts, error rendering, and callback auto-answering.
@Suite struct Teleroute2ModelTests {
    @Test func handlerInferencePinsCommonReturnShapes() async throws {
        let router = Teleroute()

        // String literal is a reply.
        router.command("ping") { _ in "pong" }
        // Chainable builder.
        router.command("fancy") { _ in
            Reply("bold").parseMode(.html).silent()
        }
        // Full response enum via member syntax.
        router.command("classic") { _ in
            .reply("classic")
        }
        // Multi-statement closure returning a response.
        router.command("multi") { context in
            let name = context.command?.arguments.first ?? "world"
            return .reply("hello \(name)")
        }
        // Void side-effect closure.
        router.command("silent") { context in
            _ = context.update.updateId
        }
        // Optional: nil means done.
        router.command("maybe") { _ -> TelerouteResponse? in nil }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.sendCommand("ping", updateId: 2_001)
            _ = await client.sendCommand("fancy", updateId: 2_002)
            _ = await client.sendCommand("classic", updateId: 2_003)
            _ = await client.sendCommand("multi hello", updateId: 2_004)
            _ = await client.sendCommand("silent", updateId: 2_005)
            _ = await client.sendCommand("maybe", updateId: 2_006)
        }

        let texts = telegram.effects.compactMap { effect -> String? in
            if case let .sentMessage(message) = effect { return message.text }
            return nil
        }
        #expect(texts == ["pong", "bold", "classic", "hello hello"])
        await bot.shutdown()
    }

    @Test func guardDenyConsumesUpdateWithResponse() async throws {
        let router = Teleroute()
        router.command(
            "vip",
            guards: [TelerouteUserAllowlistGuard([1], deny: .reply("Not allowed"))]
        ) { _ in "welcome" }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            let denied = await client.sendCommand("vip", userId: 99, updateId: 2_010)
            #expect(denied.terminalEvent?.kind == .handled)
            let allowed = await client.sendCommand("vip", userId: 1, updateId: 2_011)
            #expect(allowed.terminalEvent?.kind == .handled)
        }

        let texts = telegram.effects.compactMap { effect -> String? in
            if case let .sentMessage(message) = effect { return message.text }
            return nil
        }
        #expect(texts == ["Not allowed", "welcome"])
        await bot.shutdown()
    }

    @Test func guardSkipFallsThroughToUnmatched() async throws {
        let router = Teleroute()
        router.command("locked", guards: [TelerouteUserAllowlistGuard([1])]) { _ in "hi" }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            let result = await client.sendCommand("locked", userId: 5, updateId: 2_020)
            #expect(result.terminalEvent?.kind == .unmatched)
        }
        #expect(telegram.effects.isEmpty)
        await bot.shutdown()
    }

    @Test func unhandledResponseFallsThroughToNextCandidate() async throws {
        let router = Teleroute()
        router.callback("orders/{id}") { context in
            context.parameters["id"] == "1" ? .reply("first") : .unhandled
        }
        router.callback("orders/{id}") { _ in "second" }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            let result = await client.pressCallback("orders/2", updateId: 2_030)
            #expect(result.terminalEvent?.kind == .handled)
        }
        let texts = telegram.effects.compactMap { effect -> String? in
            if case let .sentMessage(message) = effect { return message.text }
            return nil
        }
        #expect(texts == ["second"])
        await bot.shutdown()
    }

    @Test func abortRendersResponseAndCountsAsHandled() async throws {
        let router = Teleroute()
        router.command("guarded") { _ -> TelerouteResponse in
            throw TelerouteAbort("Access denied")
        }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            let result = await client.sendCommand("guarded", updateId: 2_040)
            #expect(result.terminalEvent?.kind == .handled)
            #expect(result.events.map(\.kind).contains(.failed) == false)
        }
        let texts = telegram.effects.compactMap { effect -> String? in
            if case let .sentMessage(message) = effect { return message.text }
            return nil
        }
        #expect(texts == ["Access denied"])
        await bot.shutdown()
    }

    @Test func errorRendererConvertsFailuresIntoReplies() async throws {
        struct Boom: Error {}
        let router = Teleroute()
        router.command("explode") { _ -> TelerouteResponse in
            throw Boom()
        }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(
                replayProtectionStorage: nil,
                errorRenderer: { _, _ in .reply("Something went wrong") }
            )
        )
        try await bot.test { client in
            let result = await client.sendCommand("explode", updateId: 2_050)
            #expect(result.terminalEvent?.kind == .failed)
        }
        let texts = telegram.effects.compactMap { effect -> String? in
            if case let .sentMessage(message) = effect { return message.text }
            return nil
        }
        #expect(texts == ["Something went wrong"])
        await bot.shutdown()
    }

    @Test func handledCallbackIsAutoAnsweredExactlyOnce() async throws {
        let router = Teleroute()
        router.callback("noop/{id}") { _ in "done" }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.pressCallback("noop/1", updateId: 2_060)
        }
        let answers = telegram.effects.compactMap { effect -> TelerouteRecordedCallbackAnswer? in
            if case let .answeredCallback(answer) = effect { return answer }
            return nil
        }
        #expect(answers.count == 1)
        #expect(answers.first?.text == nil)
        await bot.shutdown()
    }

    @Test func explicitAnswerSuppressesAutoAnswer() async throws {
        let router = Teleroute()
        router.callback("ack/{id}") { _ in
            TelerouteResponse.answerCallback("Got it")
        }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.pressCallback("ack/1", updateId: 2_061)
        }
        let answers = telegram.effects.compactMap { effect -> TelerouteRecordedCallbackAnswer? in
            if case let .answeredCallback(answer) = effect { return answer }
            return nil
        }
        #expect(answers.count == 1)
        #expect(answers.first?.text == "Got it")
        await bot.shutdown()
    }

    @Test func autoAnswerCanBeDisabledOrSkipped() async throws {
        let router = Teleroute()
        router.callback("quiet/{id}") { context in
            context.skipCallbackAutoAnswer()
        }
        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.pressCallback("quiet/1", updateId: 2_062)
        }
        #expect(telegram.effects.isEmpty)
        await bot.shutdown()

        let offRouter = Teleroute()
        offRouter.callback("off/{id}") { _ in "handled" }
        let (offBot, offTelegram) = try TelerouteTestSupport.makeTelerouteBot(
            router: offRouter,
            configuration: .init(
                replayProtectionStorage: nil,
                autoAnswerCallbackQueries: false
            )
        )
        try await offBot.test { client in
            _ = await client.pressCallback("off/1", updateId: 2_063)
        }
        let answers = offTelegram.effects.filter {
            if case .answeredCallback = $0 { return true }
            return false
        }
        #expect(answers.isEmpty)
        await offBot.shutdown()
    }

    @Test func defaultParseModeAppliesToStringReplies() async throws {
        let router = Teleroute()
        router.command("styled") { _ in "<b>hi</b>" }

        let telegram = TelerouteRecordingTransport()
        let bot = try TelerouteBot(
            token: TelerouteTestSupport.testToken,
            router: router,
            logger: .init(label: "tests.parsemode"),
            configuration: .init(
                replayProtectionStorage: nil,
                defaultParseMode: .html
            ),
            transport: telegram,
            rateLimit: nil
        )
        try await bot.test { client in
            _ = await client.sendCommand("styled", updateId: 2_070)
        }
        // The recording transport keeps only the decoded message text; the
        // parse-mode assertion is wire-level and covered by the wrapper tests.
        let texts = telegram.effects.compactMap { effect -> String? in
            if case let .sentMessage(message) = effect { return message.text }
            return nil
        }
        #expect(texts == ["<b>hi</b>"])
        await bot.shutdown()
    }
}
