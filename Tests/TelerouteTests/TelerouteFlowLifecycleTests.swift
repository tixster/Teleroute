import Foundation
import Testing
import Teleroute
import TelerouteTestSupport

/// A flow used to be unable to learn about any of the endings it did not ask
/// for — interrupted by a command, expired, or replaced. These cover the hooks
/// that close that gap, and the guarantee that without a hook the old
/// cancellation behavior is unchanged.
@Suite struct TelerouteFlowLifecycleTests {
    private let key = TelerouteFlowKey(chatId: 1, userId: 1)

    /// The headline case: `/help` arrives mid-flow, and the flow is told.
    @Test func flowLearnsItWasInterruptedByACommand() async throws {
        let seen = TelerouteTestRecorder<String>()
        let router = Teleroute()
        router.flow(EndReportingFlow(seen: seen))
        router.command("help") { (_: TelerouteContext) -> Void in
            await seen.record("global /help ran")
        }

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.sendCommand("endflow", updateId: 4_101)
            _ = await client.sendCommand("help", updateId: 4_102)
        }
        await bot.shutdown()

        let recorded = await seen.waitForCount(2)
        // The flow is notified, and the command still reaches its own route —
        // the pre-existing fall-through must be preserved.
        #expect(recorded.contains("ended: interrupted(command: \"help\")"))
        #expect(recorded.contains("global /help ran"))
    }

    @Test func flowLearnsItExpired() async throws {
        let seen = TelerouteTestRecorder<String>()
        let storage = TelerouteMockFlowStorage()
        let router = Teleroute()
        router.flow(EndReportingFlow(seen: seen))

        await storage.setSession(
            .init(
                id: EndReportingFlow.id, step: "waiting", values: .init(),
                createdAt: .distantPast, updatedAt: .distantPast, expiresAt: .distantPast
            ),
            for: self.key
        )

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(flowStorage: storage, replayProtectionStorage: nil)
        )
        try await bot.test { client in
            _ = await client.sendMessage("anything", updateId: 4_111)
        }
        await bot.shutdown()

        #expect(await seen.waitForCount(1) == ["ended: expired"])
    }

    /// Without a hook, the configured policy must decide exactly as before.
    /// The default policy had no test at all until now.
    @Test func withoutAHookTheDefaultPolicyStillCancels() async throws {
        let storage = TelerouteMockFlowStorage()
        let router = Teleroute()
        router.flow(PlainEndFlow())
        router.command("help") { (_: TelerouteContext) -> Void in }

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(flowStorage: storage, replayProtectionStorage: nil)
        )
        try await bot.test { client in
            _ = await client.sendCommand("plainend", updateId: 4_121)
            _ = await client.sendCommand("help", updateId: 4_122)
        }
        await bot.shutdown()

        #expect(await storage.contains(self.key) == false)
    }

    @Test func withoutAHookManualPolicyStillPreserves() async throws {
        let storage = TelerouteMockFlowStorage()
        let router = Teleroute()
        router.flow(PlainEndFlow())
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
            _ = await client.sendCommand("plainend", updateId: 4_131)
            _ = await client.sendCommand("help", updateId: 4_132)
        }
        await bot.shutdown()

        #expect(await storage.contains(self.key))
    }

    /// `associatedtype FlowState` is deliberately not named `State`: inference
    /// would bind it to a conformer's nested type and break the conformance.
    @Test func flowWithNestedNonCodableStateTypeStillConforms() {
        // Compiling this file at all is the assertion.
        #expect(NestedStateFlow.id.isEmpty == false)
    }
}

// MARK: - Flows

private struct EndReportingFlow: TelerouteFlow {
    let seen: TelerouteTestRecorder<String>

    enum Step: String, Sendable { case waiting }

    func boot(flow: TelerouteFlowGroup<EndReportingFlow>) {
        let seen = self.seen
        flow.onEnd { _, reason in
            await seen.record("ended: \(reason)")
        }
        flow.start("endflow", at: .waiting) { _ in }
        flow.message(at: .waiting) { _ in }
    }
}

private struct PlainEndFlow: TelerouteFlow {
    enum Step: String, Sendable { case waiting }

    func boot(flow: TelerouteFlowGroup<PlainEndFlow>) {
        flow.start("plainend", at: .waiting) { _ in }
        flow.message(at: .waiting) { _ in }
    }
}

/// Guards the `FlowState` naming decision: `State` here is unrelated to the
/// flow's session state and does not conform to `Codable`.
private struct NestedStateFlow: TelerouteFlow {
    enum Step: String, Sendable { case only }
    struct State: Sendable { var counter = 0 }

    func boot(flow: TelerouteFlowGroup<NestedStateFlow>) {
        flow.start("nested", at: .only) { _ in }
    }
}

// MARK: - Replacement

/// `start` replacing a live session used to discard it with no metric and no
/// notification at all — a session simply vanished from the outcome histogram.
@Suite struct TelerouteFlowReplacementTests {
    @Test func replacingALiveSessionReportsItAndNotifiesTheFlow() async throws {
        let seen = TelerouteTestRecorder<String>()
        let sink = ReplacementSink()

        let router = Teleroute()
        router.flow(ReplacedFlow(seen: seen))
        router.command("takeover") { context in
            try await context.start(ReplacingFlow.self, at: .only)
        }
        router.flow(ReplacingFlow())

        // `.manual` so the interrupting command does not tear the session
        // down before it reaches the global route — this test is about
        // replacement, not interruption.
        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(
                replayProtectionStorage: nil,
                flowCancellationPolicy: .manual,
                metricsSink: sink
            )
        )
        try await bot.test { client in
            _ = await client.sendCommand("replaced", updateId: 4_301)
            _ = await client.sendCommand("takeover", updateId: 4_302)
        }
        await bot.shutdown()

        // The outgoing flow is told who took its place...
        let recorded = await seen.waitForCount(1)
        #expect(recorded.first == "replaced(by: \"\(ReplacingFlow.id)\")")
        // ...and the ending reaches the metrics sink, mapped onto .cancelled
        // because TelerouteFlowOutcome has no .replaced case to add additively.
        #expect(await sink.endedFlowIDs == [ReplacedFlow.id])
        #expect(await sink.outcomes == [.cancelled])
    }

    @Test func startingWithNoLiveSessionReportsNothing() async throws {
        let sink = ReplacementSink()
        let router = Teleroute()
        router.flow(ReplacingFlow())
        router.command("takeover") { context in
            try await context.start(ReplacingFlow.self, at: .only)
        }

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(replayProtectionStorage: nil, metricsSink: sink)
        )
        try await bot.test { client in
            _ = await client.sendCommand("takeover", updateId: 4_311)
        }
        await bot.shutdown()

        #expect(await sink.outcomes.isEmpty)
    }
}

private actor ReplacementSink: TelerouteMetricsSink {
    private(set) var outcomes: [TelerouteFlowOutcome] = []
    private(set) var endedFlowIDs: [String] = []

    func recordFlowEnded(
        flowID: String,
        step: String,
        outcome: TelerouteFlowOutcome,
        age: Duration,
        chatId: Int64?,
        userId: Int64?
    ) async {
        self.outcomes.append(outcome)
        self.endedFlowIDs.append(flowID)
    }
}

private struct ReplacedFlow: TelerouteFlow {
    let seen: TelerouteTestRecorder<String>

    enum Step: String, Sendable { case waiting }

    func boot(flow: TelerouteFlowGroup<ReplacedFlow>) {
        let seen = self.seen
        flow.onEnd { _, reason in
            await seen.record("\(reason)")
        }
        flow.start("replaced", at: .waiting) { _ in }
        flow.message(at: .waiting) { _ in }
    }
}

private struct ReplacingFlow: TelerouteFlow {
    enum Step: String, Sendable { case only }

    func boot(flow: TelerouteFlowGroup<ReplacingFlow>) {
        flow.message(at: .only) { _ in }
    }
}
