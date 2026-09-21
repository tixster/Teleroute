import Foundation
import Testing
import Teleroute
import TelerouteTestSupport

/// `onInterrupt` lets a flow decide what a command it does not handle should do
/// to its session, replacing the all-or-nothing configured policy.
@Suite struct TelerouteFlowInterruptionTests {
    private let key = TelerouteFlowKey(chatId: 1, userId: 1)

    /// `.keep` overrides the default cancelling policy: the session survives
    /// and the command still routes normally.
    @Test func keepOverridesTheCancellingPolicy() async throws {
        let ran = TelerouteTestRecorder<String>()
        let storage = TelerouteMockFlowStorage()
        let router = Teleroute()
        router.flow(DecidingFlow(decision: .keep, ran: ran))
        router.command("help") { (_: TelerouteContext) -> Void in
            await ran.record("global /help")
        }

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(flowStorage: storage, replayProtectionStorage: nil)
        )
        try await bot.test { client in
            _ = await client.sendCommand("decide", updateId: 4_201)
            _ = await client.sendCommand("help", updateId: 4_202)
            _ = await client.sendMessage("still captured", updateId: 4_203)
        }
        await bot.shutdown()

        let recorded = await ran.waitForCount(3)
        #expect(recorded.contains("interrupted by help"))
        #expect(recorded.contains("global /help"))
        // The decisive assertion: the flow kept capturing afterwards.
        #expect(recorded.contains("step saw: still captured"))
        #expect(await storage.contains(self.key))
    }

    /// `.handled` swallows the command: the flow answers and the global route
    /// with the same name must NOT run.
    @Test func handledSwallowsTheCommand() async throws {
        let ran = TelerouteTestRecorder<String>()
        let storage = TelerouteMockFlowStorage()
        let router = Teleroute()
        router.flow(DecidingFlow(decision: .handled(.reply("Finish signup first.")), ran: ran))
        router.command("help") { (_: TelerouteContext) -> Void in
            await ran.record("global /help")
        }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(flowStorage: storage, replayProtectionStorage: nil)
        )
        try await bot.test { client in
            _ = await client.sendCommand("decide", updateId: 4_211)
            _ = await client.sendCommand("help", updateId: 4_212)
        }
        await bot.shutdown()

        let texts = telegram.effects.compactMap { effect -> String? in
            guard case let .sentMessage(message) = effect else { return nil }
            return message.text
        }
        #expect(texts.contains("Finish signup first."))
        #expect(await ran.values.contains("global /help") == false)
        #expect(await storage.contains(self.key))
    }

    /// `.cancel` overrides a preserving policy in the other direction.
    @Test func cancelOverridesAPreservingPolicy() async throws {
        let storage = TelerouteMockFlowStorage()
        let router = Teleroute()
        router.flow(DecidingFlow(decision: .cancel, ran: TelerouteTestRecorder<String>()))
        router.command("help") { (_: TelerouteContext) -> Void in }

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(
                flowStorage: storage,
                replayProtectionStorage: nil,
                flowCancellationPolicy: .manual
            )
        )
        try await bot.test { client in
            _ = await client.sendCommand("decide", updateId: 4_221)
            _ = await client.sendCommand("help", updateId: 4_222)
        }
        await bot.shutdown()

        #expect(await storage.contains(self.key) == false)
    }

    /// `.suspend` parks the session: it survives, stops capturing, and comes
    /// back with `resumeFlow()`.
    @Test func suspendParksTheSessionUntilResumed() async throws {
        let ran = TelerouteTestRecorder<String>()
        let storage = TelerouteMockFlowStorage()
        let router = Teleroute()
        router.flow(DecidingFlow(decision: .suspend, ran: ran))
        router.command("help") { (_: TelerouteContext) -> Void in }
        router.text("loose") { (_: TelerouteContext) -> Void in
            await ran.record("global text route")
        }
        router.command("resume") { context in
            try await context.resumeFlow()
        }

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(flowStorage: storage, replayProtectionStorage: nil)
        )
        try await bot.test { client in
            _ = await client.sendCommand("decide", updateId: 4_231)
            _ = await client.sendCommand("help", updateId: 4_232)
            _ = await client.sendMessage("loose", updateId: 4_233)
        }

        // Suspended: kept in storage, but no longer intercepting.
        let suspended = try #require(await storage.session(for: self.key))
        #expect(suspended.isSuspended)
        #expect(await ran.values.contains("global text route"))

        try await bot.test { client in
            _ = await client.sendCommand("resume", updateId: 4_234)
            _ = await client.sendMessage("back in the flow", updateId: 4_235)
        }
        await bot.shutdown()

        let resumed = try #require(await storage.session(for: self.key))
        #expect(resumed.isSuspended == false)
        #expect(await ran.values.contains("step saw: back in the flow"))
    }

    /// A suspended session must not re-fire the hook on every later command.
    @Test func suspendedSessionDoesNotRefireTheHook() async throws {
        let ran = TelerouteTestRecorder<String>()
        let router = Teleroute()
        router.flow(DecidingFlow(decision: .suspend, ran: ran))
        router.command("help") { (_: TelerouteContext) -> Void in }

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.sendCommand("decide", updateId: 4_241)
            _ = await client.sendCommand("help", updateId: 4_242)
            _ = await client.sendCommand("help", updateId: 4_243)
        }
        await bot.shutdown()

        let interrupts = await ran.values.filter { $0.hasPrefix("interrupted") }
        #expect(interrupts.count == 1)
    }

    /// A hook that sends a message runs inside the per-session serialized
    /// section. If it ever re-entered that queue it would deadlock, so this
    /// completing at all is the assertion.
    @Test func hookSendingAMessageDoesNotDeadlock() async throws {
        let router = Teleroute()
        router.flow(ChattyInterruptFlow())
        router.command("help") { (_: TelerouteContext) -> Void in }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.sendCommand("chatty", updateId: 4_251)
            _ = await client.sendCommand("help", updateId: 4_252)
        }
        await bot.shutdown()

        let texts = telegram.effects.compactMap { effect -> String? in
            guard case let .sentMessage(message) = effect else { return nil }
            return message.text
        }
        #expect(texts.contains("still here"))
    }
}

// MARK: - Flows

private struct DecidingFlow: TelerouteFlow {
    let decision: TelerouteFlowInterruption
    let ran: TelerouteTestRecorder<String>

    enum Step: String, Sendable { case waiting }

    func boot(flow: TelerouteFlowGroup<DecidingFlow>) {
        let decision = self.decision
        let ran = self.ran
        flow.onInterrupt { _, command in
            await ran.record("interrupted by \(command.name)")
            return decision
        }
        flow.start("decide", at: .waiting) { _ in }
        flow.message(at: .waiting) { context in
            await ran.record("step saw: \(context.message?.text ?? "")")
        }
    }
}

private struct ChattyInterruptFlow: TelerouteFlow {
    enum Step: String, Sendable { case waiting }

    func boot(flow: TelerouteFlowGroup<ChattyInterruptFlow>) {
        flow.onInterrupt { context, _ in
            try? await context.reply("still here")
            return .keep
        }
        flow.start("chatty", at: .waiting) { _ in }
        flow.message(at: .waiting) { _ in }
    }
}
