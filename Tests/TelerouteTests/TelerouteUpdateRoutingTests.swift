import Testing
@_spi(Testing) @testable import Teleroute
import TelerouteTestSupport

/// Tests for full update-kind routing: plain messages, text routes, typed
/// update-kind sugar, the unmatched hook, and allowed-updates derivation.
@Suite struct TelerouteUpdateRoutingTests {
    @Test func plainMessageRouteHandlesNonCommandText() async throws {
        let router = Teleroute()
        router.message(.text) { context in
            "echo: \(context.message?.text ?? "")"
        }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            let result = await client.sendMessage("hello there", updateId: 3_001)
            #expect(result.terminalEvent?.kind == .handled)
            #expect(result.terminalEvent?.routeKind == .message)
        }
        #expect(self.sentTexts(telegram) == ["echo: hello there"])
        await bot.shutdown()
    }

    @Test func commandRouteWinsOverTextRoute() async throws {
        let router = Teleroute()
        router.command("start") { _ in "command" }
        router.message(.text) { _ in "message" }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.sendCommand("start", updateId: 3_002)
        }
        #expect(self.sentTexts(telegram) == ["command"])
        await bot.shutdown()
    }

    @Test func messageSourcesFilterEditedMessages() async throws {
        let router = Teleroute()
        router.message(.text) { _ in "fresh" }
        router.message(.text, from: [.edited]) { _ in "edited" }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.execute(TelerouteTestSupport.makeMessageUpdate(text: "a", updateId: 3_010))
            _ = await client.execute(TelerouteTestSupport.makeEditedMessageUpdate(text: "b", updateId: 3_011))
        }
        #expect(self.sentTexts(telegram) == ["fresh", "edited"])
        await bot.shutdown()
    }

    @Test func contentFiltersMatchPhotoMessages() async throws {
        let router = Teleroute()
        router.message(.photo) { context in
            "photo: \(context.message?.caption ?? "-")"
        }
        router.message(.text) { _ in "text" }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.execute(TelerouteTestSupport.makePhotoMessageUpdate(caption: "cat", updateId: 3_020))
            _ = await client.execute(TelerouteTestSupport.makeMessageUpdate(text: "hi", updateId: 3_021))
        }
        #expect(self.sentTexts(telegram) == ["photo: cat", "text"])
        await bot.shutdown()
    }

    @Test func textRoutesMatchExactPrefixAndRegex() async throws {
        let router = Teleroute()
        router.text("ping") { _ in "pong" }
        router.text(prefix: "!") { context in
            "bang: \(context.message?.text ?? "")"
        }
        router.text(matching: /order-(\d+)/) { _ in "order" }
        router.message(.text) { _ in "fallback" }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.sendMessage("ping", updateId: 3_030)
            _ = await client.sendMessage("!roll", updateId: 3_031)
            _ = await client.sendMessage("see order-42 please", updateId: 3_032)
            _ = await client.sendMessage("nothing", updateId: 3_033)
        }
        #expect(self.sentTexts(telegram) == ["pong", "bang: !roll", "order", "fallback"])
        await bot.shutdown()
    }

    @Test func typedSugarDeliversPayloads() async throws {
        let recorder = TelerouteTestRecorder<String>()
        let router = Teleroute()
        router.inlineQuery { query, _ in
            await recorder.record("inline:\(query.query)")
        }
        router.messageReaction { reaction, _ in
            await recorder.record("reaction:\(reaction.chat.id)")
        }
        router.preCheckoutQuery { query, _ in
            await recorder.record("precheckout:\(query.invoicePayload)")
        }
        router.chatJoinRequest { request, _ in
            await recorder.record("join:\(request.from.id)")
        }
        router.chatMember { updated, _ in
            await recorder.record("member:\(updated.chat.id)")
        }
        router.pollAnswer { answer, _ in
            await recorder.record("poll:\(answer.optionIds)")
        }

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.execute([
                TelerouteTestSupport.makeInlineQueryUpdate(query: "cats", updateId: 3_040),
                TelerouteTestSupport.makeReactionUpdate(emoji: "👍", chatId: 5, updateId: 3_041),
                TelerouteTestSupport.makePreCheckoutUpdate(payload: "inv-1", updateId: 3_042),
                TelerouteTestSupport.makeJoinRequestUpdate(userId: 9, updateId: 3_043),
                TelerouteTestSupport.makeChatMemberUpdate(chatId: 7, updateId: 3_044),
                TelerouteTestSupport.makePollAnswerUpdate(optionIds: [2], updateId: 3_045),
            ])
        }
        let values = await recorder.waitForCount(6)
        #expect(Set(values) == [
            "inline:cats", "reaction:5", "precheckout:inv-1",
            "join:9", "member:7", "poll:[2]",
        ])
        await bot.shutdown()
    }

    @Test func genericOnRouteHandlesMultipleKinds() async throws {
        let recorder = TelerouteTestRecorder<String>()
        let router = Teleroute()
        router.on(.messageReaction, .chatJoinRequest) { context in
            await recorder.record("kind:\(context.updateKind?.rawValue ?? "?")")
        }

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.execute([
                TelerouteTestSupport.makeReactionUpdate(emoji: "🔥", updateId: 3_050),
                TelerouteTestSupport.makeJoinRequestUpdate(updateId: 3_051),
            ])
        }
        let values = await recorder.waitForCount(2)
        #expect(Set(values) == ["kind:message_reaction", "kind:chat_join_request"])
        await bot.shutdown()
    }

    @Test func unmatchedHookRunsLastAndCanFallThrough() async throws {
        let router = Teleroute()
        router.command("known") { _ in "known" }
        router.unmatched { context in
            context.updateKind == .message ? .reply("caught") : .unhandled
        }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            let caught = await client.sendMessage("stray", updateId: 3_060)
            #expect(caught.terminalEvent?.kind == .handled)
            let reaction = await client.execute(
                TelerouteTestSupport.makeReactionUpdate(emoji: "👀", updateId: 3_061)
            )
            #expect(reaction.terminalEvent?.kind == .unmatched)
        }
        #expect(self.sentTexts(telegram) == ["caught"])
        await bot.shutdown()
    }

    @Test func allowedUpdatesDerivedFromRegisteredRoutes() throws {
        let router = Teleroute()
        router.command("start") { _ in "hi" }
        router.callback("a/{b}") { _ in "cb" }
        router.messageReaction { _, _ in "r" }

        let runtime = TelerouteRuntime(
            bot: try TelerouteTestSupport.makeClient(),
            logger: .init(label: "tests.allowed"),
            configuration: .init(),
            storage: router.storage
        )
        let automatic = runtime.resolvedAllowedUpdates(.automatic)
        #expect(automatic?.contains("message") == true)
        #expect(automatic?.contains("edited_message") == true)
        #expect(automatic?.contains("callback_query") == true)
        #expect(automatic?.contains("message_reaction") == true)
        #expect(automatic?.contains("poll") == false)

        #expect(runtime.resolvedAllowedUpdates(.explicit([.poll])) == ["poll"])
        #expect(runtime.resolvedAllowedUpdates(.all)?.count == UpdateKind.allCases.count)
    }

    @Test func allowedUpdatesWidenToAllWithUnmatchedHook() throws {
        let router = Teleroute()
        router.unmatched { _ in "anything" }
        let runtime = TelerouteRuntime(
            bot: try TelerouteTestSupport.makeClient(),
            logger: .init(label: "tests.allowed.all"),
            configuration: .init(),
            storage: router.storage
        )
        #expect(
            runtime.resolvedAllowedUpdates(.automatic)?.count == UpdateKind.allCases.count
        )
    }

    @Test func emptyRouterKeepsTelegramDefaultAllowedUpdates() throws {
        let router = Teleroute()
        let runtime = TelerouteRuntime(
            bot: try TelerouteTestSupport.makeClient(),
            logger: .init(label: "tests.allowed.default"),
            configuration: .init(),
            storage: router.storage
        )
        #expect(runtime.resolvedAllowedUpdates(.automatic) == nil)
    }

    private func sentTexts(_ telegram: TelerouteRecordingTransport) -> [String] {
        telegram.effects.compactMap { effect -> String? in
            if case let .sentMessage(message) = effect { return message.text }
            return nil
        }
    }
}
