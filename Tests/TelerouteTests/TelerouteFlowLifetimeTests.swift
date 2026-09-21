import Foundation
import Testing
import Teleroute
import TelerouteTestSupport

/// Flow sessions used to live forever: an abandoned conversation captured its
/// chat until the process restarted. These cover the opt-in TTL and the
/// persistence format shared stores need.
@Suite struct TelerouteFlowLifetimeTests {
    private let key = TelerouteFlowKey(chatId: 1, userId: 1)

    /// An expired session must not capture the update — it falls through to
    /// ordinary routing — and must be dropped from the store.
    @Test func expiredSessionFallsThroughToNormalRoutingAndIsRemoved() async throws {
        let storage = TelerouteMockFlowStorage()
        let reached = TelerouteTestRecorder<String>()

        let router = Teleroute()
        router.flow(CaptureFlow(reached: reached))
        router.text("go") { (_: TelerouteContext) -> Void in
            await reached.record("plain route")
        }

        // Seed a session that expired in the past.
        await storage.setSession(
            .init(
                id: CaptureFlow.id,
                step: "waiting",
                values: .init(),
                createdAt: .distantPast,
                updatedAt: .distantPast,
                expiresAt: .distantPast
            ),
            for: self.key
        )

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(flowStorage: storage, replayProtectionStorage: nil)
        )
        try await bot.test { client in
            _ = await client.sendMessage("go", updateId: 6_001)
        }
        await bot.shutdown()

        #expect(await reached.waitForCount(1) == ["plain route"])
        #expect(await storage.contains(self.key) == false)
    }

    /// A live session still captures, so the TTL only affects idle ones.
    @Test func unexpiredSessionStillCaptures() async throws {
        let storage = TelerouteMockFlowStorage()
        let reached = TelerouteTestRecorder<String>()

        let router = Teleroute()
        router.flow(CaptureFlow(reached: reached))
        router.text("go") { (_: TelerouteContext) -> Void in
            await reached.record("plain route")
        }

        await storage.setSession(
            .init(
                id: CaptureFlow.id,
                step: "waiting",
                values: .init(),
                createdAt: Date(),
                updatedAt: Date(),
                expiresAt: Date().addingTimeInterval(3_600)
            ),
            for: self.key
        )

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(flowStorage: storage, replayProtectionStorage: nil)
        )
        try await bot.test { client in
            _ = await client.sendMessage("go", updateId: 6_011)
        }
        await bot.shutdown()

        #expect(await reached.waitForCount(1) == ["flow step"])
    }

    /// The default must not change behavior for anyone: with no TTL configured,
    /// a session started today carries no deadline at all.
    @Test func defaultConfigurationLeavesSessionsWithoutExpiry() async throws {
        let storage = TelerouteMockFlowStorage()

        let router = Teleroute()
        router.flow(CaptureFlow(reached: TelerouteTestRecorder<String>()))

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(flowStorage: storage, replayProtectionStorage: nil)
        )
        try await bot.test { client in
            _ = await client.sendCommand("capture", updateId: 6_021)
        }
        await bot.shutdown()

        let session = try #require(await storage.session(for: self.key))
        #expect(session.expiresAt == nil)
        #expect(session.isExpired() == false)
    }

    @Test func configuredTTLStampsAnExpiryOnStart() async throws {
        let storage = TelerouteMockFlowStorage()

        let router = Teleroute()
        router.flow(CaptureFlow(reached: TelerouteTestRecorder<String>()))

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(
                flowStorage: storage,
                replayProtectionStorage: nil,
                flowSessionTTL: .seconds(600)
            )
        )
        try await bot.test { client in
            _ = await client.sendCommand("capture", updateId: 6_031)
        }
        await bot.shutdown()

        let session = try #require(await storage.session(for: self.key))
        let expiresAt = try #require(session.expiresAt)
        #expect(expiresAt > Date())
        #expect(expiresAt <= Date().addingTimeInterval(601))
    }

    /// A per-flow override wins over the configured default.
    @Test func perFlowTTLOverridesConfiguration() async throws {
        let storage = TelerouteMockFlowStorage()

        let router = Teleroute()
        router.flow(ShortLivedFlow())

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(
                flowStorage: storage,
                replayProtectionStorage: nil,
                flowSessionTTL: .seconds(86_400)
            )
        )
        try await bot.test { client in
            _ = await client.sendCommand("short", updateId: 6_041)
        }
        await bot.shutdown()

        let session = try #require(await storage.session(for: self.key))
        let expiresAt = try #require(session.expiresAt)
        // The flow's own 60s, not the configured day.
        #expect(expiresAt <= Date().addingTimeInterval(61))
    }

    /// Sliding expiry: advancing a step pushes the deadline out.
    @Test func transitionRefreshesExpiry() async throws {
        let storage = TelerouteMockFlowStorage()

        let router = Teleroute()
        router.flow(TwoStepFlow())

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(
                flowStorage: storage,
                replayProtectionStorage: nil,
                flowSessionTTL: .seconds(600)
            )
        )
        try await bot.test { client in
            _ = await client.sendCommand("twostep", updateId: 6_051)
        }
        let afterStart = try #require(await storage.session(for: self.key)?.expiresAt)
        let createdAt = try #require(await storage.session(for: self.key)?.createdAt)

        try await bot.test { client in
            _ = await client.sendMessage("next", updateId: 6_052)
        }
        await bot.shutdown()

        let afterTransition = try #require(await storage.session(for: self.key))
        #expect(afterTransition.step == "second")
        #expect(afterTransition.expiresAt ?? .distantPast >= afterStart)
        // createdAt is never rewritten, so session age stays measurable.
        #expect(afterTransition.createdAt == createdAt)
    }

    @Test func inMemoryStorageSweepsExpiredSessions() async throws {
        let storage = TelerouteInMemoryFlowStorage()
        let live = TelerouteFlowKey(chatId: 2, userId: 2)

        await storage.setSession(
            .init(
                id: "F", step: "s", values: .init(),
                createdAt: .distantPast, updatedAt: .distantPast, expiresAt: .distantPast
            ),
            for: self.key
        )
        await storage.setSession(
            .init(
                id: "F", step: "s", values: .init(),
                createdAt: Date(), updatedAt: Date(),
                expiresAt: Date().addingTimeInterval(3_600)
            ),
            for: live
        )

        await storage.removeExpiredSessions(at: Date())

        #expect(await storage.session(for: self.key) == nil)
        #expect(await storage.session(for: live) != nil)
    }
}

/// The persistence contract a Redis/Postgres storage implementation depends on.
@Suite struct TelerouteFlowSessionCodingTests {
    @Test func sessionRoundTripsThroughCanonicalCoding() throws {
        let original = TelerouteFlowSession(
            id: "SignupFlow",
            step: "confirm",
            values: ["name": "Alice", "amount": "12.5"],
            createdAt: Date(timeIntervalSince1970: 1_000_000),
            updatedAt: Date(timeIntervalSince1970: 1_000_500),
            expiresAt: Date(timeIntervalSince1970: 1_001_000)
        )

        let decoded = try TelerouteFlowSessionCoding.decode(
            TelerouteFlowSessionCoding.encode(original)
        )

        #expect(decoded == original)
        #expect(try decoded.values.require("name") == "Alice")
    }

    /// Flow values persist as a plain object, so a stored record stays legible.
    @Test func valuesEncodeAsAFlatObject() throws {
        let encoded = try TelerouteFlowSessionCoding.encodeToString(
            .init(id: "F", step: "s", values: ["name": "Alice"])
        )
        let json = try JSONSerialization.jsonObject(with: Data(encoded.utf8)) as! [String: Any]
        let session = try #require(json["session"] as? [String: Any])

        #expect(session["values"] as? [String: String] == ["name": "Alice"])
        #expect(json["v"] as? Int == TelerouteFlowSessionCoding.schemaVersion)
    }

    /// Records written before timestamps existed must still decode, so enabling
    /// this on a running deployment does not orphan live sessions.
    @Test func recordWithoutTimestampsStillDecodes() throws {
        let legacy = #"{"id":"SignupFlow","step":"name","values":{"name":"Alice"}}"#

        let decoded = try TelerouteFlowSessionCoding.decode(legacy)

        #expect(decoded.id == "SignupFlow")
        #expect(decoded.step == "name")
        #expect(decoded.values["name"] == "Alice")
        #expect(decoded.expiresAt == nil)
        #expect(decoded.isExpired() == false)
    }

    @Test func flowKeyStorageKeyRoundTrips() {
        let withUser = TelerouteFlowKey(chatId: 12, userId: 34)
        #expect(withUser.storageKey == "12:34")
        #expect(TelerouteFlowKey(storageKey: "12:34") == withUser)

        let withoutUser = TelerouteFlowKey(chatId: -100, userId: nil)
        #expect(withoutUser.storageKey == "-100:-")
        #expect(TelerouteFlowKey(storageKey: "-100:-") == withoutUser)

        #expect(TelerouteFlowKey(storageKey: "nonsense") == nil)
    }

    @Test func timeToLiveReportsRemainingTime() {
        let session = TelerouteFlowSession(
            id: "F", step: "s", values: .init(),
            createdAt: Date(), updatedAt: Date(),
            expiresAt: Date().addingTimeInterval(120)
        )
        let ttl = session.timeToLive()
        #expect(ttl != nil)
        #expect((ttl?.components.seconds ?? 0) <= 120)

        let never = TelerouteFlowSession(id: "F", step: "s", values: .init())
        #expect(never.timeToLive() == nil)
    }
}

// MARK: - Flows

private struct CaptureFlow: TelerouteFlow {
    let reached: TelerouteTestRecorder<String>

    enum Step: String, Sendable {
        case waiting
    }

    func boot(flow: TelerouteFlowGroup<CaptureFlow>) {
        let reached = self.reached
        flow.start("capture", at: .waiting) { _ in }
        flow.message(at: .waiting) { _ in
            await reached.record("flow step")
        }
    }
}

private struct ShortLivedFlow: TelerouteFlow {
    static let sessionTTL: Duration? = .seconds(60)

    enum Step: String, Sendable {
        case only
    }

    func boot(flow: TelerouteFlowGroup<ShortLivedFlow>) {
        flow.start("short", at: .only) { _ in }
        flow.message(at: .only) { _ in }
    }
}

private struct TwoStepFlow: TelerouteFlow {
    enum Step: String, Sendable {
        case first
        case second
    }

    func boot(flow: TelerouteFlowGroup<TwoStepFlow>) {
        flow.start("twostep", at: .first) { _ in }
        flow.message(at: .first) { context in
            try await context.transition(to: .second)
        }
        flow.message(at: .second) { _ in }
    }
}

// MARK: - Flow outcome metrics

/// `finish()` and `cancelFlow()` were literally the same call, so completion
/// and abandonment were indistinguishable to an operator. These cover the
/// outcome now reported to the metrics sink.
@Suite struct TelerouteFlowMetricsTests {
    @Test func finishAndCancelReportDistinctOutcomes() async throws {
        let sink = RecordingFlowMetricsSink()

        let router = Teleroute()
        router.flow(OutcomeFlow())

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(replayProtectionStorage: nil, metricsSink: sink)
        )
        try await bot.test { client in
            _ = await client.sendCommand("outcome", updateId: 5_001)
            _ = await client.sendMessage("done", updateId: 5_002)

            _ = await client.sendCommand("outcome", updateId: 5_003)
            _ = await client.sendMessage("abandon", updateId: 5_004)
        }
        await bot.shutdown()

        let outcomes = await sink.outcomes
        #expect(outcomes == [.finished, .cancelled])
    }

    @Test func expiredSessionReportsExpiredOutcome() async throws {
        let sink = RecordingFlowMetricsSink()
        let storage = TelerouteMockFlowStorage()
        let key = TelerouteFlowKey(chatId: 1, userId: 1)

        let router = Teleroute()
        router.flow(OutcomeFlow())

        await storage.setSession(
            .init(
                id: OutcomeFlow.id, step: "waiting", values: .init(),
                createdAt: .distantPast, updatedAt: .distantPast, expiresAt: .distantPast
            ),
            for: key
        )

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(
                flowStorage: storage,
                replayProtectionStorage: nil,
                metricsSink: sink
            )
        )
        try await bot.test { client in
            _ = await client.sendMessage("anything", updateId: 5_011)
        }
        await bot.shutdown()

        #expect(await sink.outcomes == [.expired])
        // Age is measured from createdAt, so an abandoned session reports a
        // long life rather than zero.
        #expect(await sink.lastAge ?? .zero > .seconds(0))
    }
}

private actor RecordingFlowMetricsSink: TelerouteMetricsSink {
    private(set) var outcomes: [TelerouteFlowOutcome] = []
    private(set) var lastAge: Duration?

    func recordFlowEnded(
        flowID: String,
        step: String,
        outcome: TelerouteFlowOutcome,
        age: Duration,
        chatId: Int64?,
        userId: Int64?
    ) async {
        self.outcomes.append(outcome)
        self.lastAge = age
    }
}

private struct OutcomeFlow: TelerouteFlow {
    enum Step: String, Sendable {
        case waiting
    }

    func boot(flow: TelerouteFlowGroup<OutcomeFlow>) {
        flow.start("outcome", at: .waiting) { _ in }
        flow.message(at: .waiting) { context in
            if context.message?.text == "done" {
                try await context.finish()
            } else {
                try await context.cancel()
            }
        }
    }
}
