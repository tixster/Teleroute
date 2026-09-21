import Foundation
import Synchronization
import Testing
import Teleroute
import TelerouteTestSupport

/// A flow step that advances a session it has already ended used to silently
/// **recreate** that session, leaving the chat captured by a flow the user had
/// finished. These cover the validate-then-write behavior that replaced it.
@Suite struct TelerouteFlowSessionIntegrityTests {
    @Test func transitionAfterFinishDoesNotResurrectTheSession() async throws {
        let outcome = TelerouteTestRecorder<String>()
        let storage = TelerouteMockFlowStorage()

        let router = Teleroute()
        router.flow(FinishThenTransitionFlow(outcome: outcome))

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(
                flowStorage: storage,
                replayProtectionStorage: nil
            )
        )
        try await bot.test { client in
            _ = await client.sendCommand("resurrect", updateId: 7_001)
            _ = await client.sendMessage("go", updateId: 7_002)
        }
        await bot.shutdown()

        #expect(await outcome.waitForCount(1) == ["flowSessionEnded"])
        // The decisive assertion: the finished session stayed finished.
        #expect(await storage.contains(TelerouteFlowKey(chatId: 1, userId: 1)) == false)
        #expect(await storage.count == 0)
    }

    @Test func transitionThrowsWhenAnotherFlowOwnsTheScope() async throws {
        let outcome = TelerouteTestRecorder<String>()
        let storage = TelerouteMockFlowStorage()
        let key = TelerouteFlowKey(chatId: 1, userId: 1)

        let router = Teleroute()
        router.flow(HijackedFlow(outcome: outcome, storage: storage, key: key))

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(
                flowStorage: storage,
                replayProtectionStorage: nil
            )
        )
        try await bot.test { client in
            _ = await client.sendCommand("hijack", updateId: 7_011)
            _ = await client.sendMessage("go", updateId: 7_012)
        }
        await bot.shutdown()

        #expect(await outcome.waitForCount(1) == ["flowSessionReplaced"])
        // The intruding session is untouched rather than overwritten.
        let session = try #require(await storage.session(for: key))
        #expect(session.id == "OtherFlow")
        #expect(session.step == "elsewhere")
    }

    /// A backend that can apply the mutation atomically must not write when the
    /// closure throws. This counts the writes to prove the guard runs before
    /// any storage mutation.
    @Test func endedSessionMutationPerformsNoWrite() async throws {
        let storage = CountingFlowStorage()
        let outcome = TelerouteTestRecorder<String>()

        let router = Teleroute()
        router.flow(FinishThenTransitionFlow(outcome: outcome))

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(
                flowStorage: storage,
                replayProtectionStorage: nil
            )
        )
        try await bot.test { client in
            _ = await client.sendCommand("resurrect", updateId: 7_021)
            _ = await client.sendMessage("go", updateId: 7_022)
        }
        await bot.shutdown()

        #expect(await outcome.waitForCount(1) == ["flowSessionEnded"])
        // One write to start the flow; the failed transition adds none.
        #expect(await storage.writes == 1)
    }

    /// `start` routes through `updateSession` like every other flow write, so
    /// an atomic backend applies it as a single operation.
    @Test func startingAFlowWritesThroughUpdateSession() async throws {
        let storage = CountingFlowStorage()

        let router = Teleroute()
        router.flow(PlainFlow())

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(
                flowStorage: storage,
                replayProtectionStorage: nil
            )
        )
        try await bot.test { client in
            _ = await client.sendCommand("plain", updateId: 7_031)
        }
        await bot.shutdown()

        #expect(await storage.updateSessionCalls == 1)
        #expect(await storage.setSessionCalls == 0)
    }
}

// MARK: - Storage doubles

/// Counts how each write reached the backend, and honors the "throwing
/// mutation performs no write" contract an atomic backend must implement.
private actor CountingFlowStorage: TelerouteFlowStorage {
    private var sessions: [TelerouteFlowKey: TelerouteFlowSession] = [:]
    private(set) var writes = 0
    private(set) var updateSessionCalls = 0
    private(set) var setSessionCalls = 0

    func session(for key: TelerouteFlowKey) async -> TelerouteFlowSession? {
        self.sessions[key]
    }

    func setSession(_ session: TelerouteFlowSession, for key: TelerouteFlowKey) async {
        self.setSessionCalls += 1
        self.writes += 1
        self.sessions[key] = session
    }

    func removeSession(for key: TelerouteFlowKey) async {
        self.sessions.removeValue(forKey: key)
    }

    @discardableResult
    func updateSession(
        for key: TelerouteFlowKey,
        _ mutation: TelerouteFlowSessionMutation
    ) async rethrows -> TelerouteFlowSession? {
        self.updateSessionCalls += 1
        // A throwing mutation aborts before any write, exactly as a Lua script
        // or a `SELECT … FOR UPDATE` transaction would.
        let updated = try mutation(self.sessions[key])
        self.writes += 1
        self.sessions[key] = updated
        return updated
    }
}

// MARK: - Flows

private struct FinishThenTransitionFlow: TelerouteFlow {
    let outcome: TelerouteTestRecorder<String>

    enum Step: String, Sendable {
        case start
        case next
    }

    func boot(flow: TelerouteFlowGroup<FinishThenTransitionFlow>) {
        let outcome = self.outcome
        flow.start("resurrect", at: .start) { _ in }
        flow.message(at: .start) { context in
            try await context.finish()
            do {
                try await context.transition(to: .next)
                await outcome.record("resurrected")
            } catch TelerouteError.flowSessionEnded {
                await outcome.record("flowSessionEnded")
            }
        }
    }
}

private struct HijackedFlow: TelerouteFlow {
    let outcome: TelerouteTestRecorder<String>
    let storage: TelerouteMockFlowStorage
    let key: TelerouteFlowKey

    enum Step: String, Sendable {
        case start
        case next
    }

    func boot(flow: TelerouteFlowGroup<HijackedFlow>) {
        let outcome = self.outcome
        let storage = self.storage
        let key = self.key
        flow.start("hijack", at: .start) { _ in }
        flow.message(at: .start) { context in
            // Another flow takes over this scope mid-step.
            await storage.setSession(
                .init(id: "OtherFlow", step: "elsewhere", values: .init()),
                for: key
            )
            do {
                try await context.transition(to: .next)
                await outcome.record("overwrote")
            } catch TelerouteError.flowSessionReplaced {
                await outcome.record("flowSessionReplaced")
            }
        }
    }
}

private struct PlainFlow: TelerouteFlow {
    enum Step: String, Sendable {
        case only
    }

    func boot(flow: TelerouteFlowGroup<PlainFlow>) {
        flow.start("plain", at: .only) { _ in }
        flow.message(at: .only) { _ in }
    }
}
