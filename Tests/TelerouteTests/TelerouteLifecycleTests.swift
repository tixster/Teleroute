import Testing
@_spi(Testing) @testable import Teleroute
import TelerouteTestSupport

/// Tests for the Service-style lifecycle: graceful draining and bot modes.
@Suite struct TelerouteLifecycleTests {
    @Test func shutdownDrainsInFlightHandlersBeforeReturning() async throws {
        let recorder = TelerouteTestRecorder<String>()
        let router = Teleroute()
        router.command("slow") { (_: TelerouteContext) -> Void in
            try? await Task.sleep(for: .milliseconds(120))
            await recorder.record("finished")
        }

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        await bot.process([
            TelerouteTestSupport.makeCommandUpdate(text: "/slow", updateId: 5_001),
        ])
        // Give the handler a moment to start, then shut down gracefully.
        try await Task.sleep(for: .milliseconds(20))
        await bot.shutdown()

        #expect(await recorder.values == ["finished"])
    }

    @Test func shutdownGracePeriodBoundsTheDrain() async throws {
        let router = Teleroute()
        router.command("stuck") { (_: TelerouteContext) -> Void in
            // Sleeps far longer than the grace period; must be cancelled.
            try? await Task.sleep(for: .seconds(30))
        }

        let telegram = TelerouteRecordingTransport()
        let bot = try TelerouteBot(
            token: TelerouteTestSupport.testToken,
            router: router,
            logger: .init(label: "tests.grace"),
            configuration: .init(
                replayProtectionStorage: nil,
                shutdownGracePeriod: .milliseconds(50)
            ),
            transport: telegram,
            rateLimit: nil
        )
        await bot.process([
            TelerouteTestSupport.makeCommandUpdate(text: "/stuck", updateId: 5_002),
        ])
        try await Task.sleep(for: .milliseconds(20))

        let clock = ContinuousClock()
        let elapsed = await clock.measure {
            await bot.shutdown()
        }
        #expect(elapsed < .seconds(5))
    }

    @Test func webhookModeStartsWithoutPolling() async throws {
        let recorder = TelerouteTestRecorder<Int64>()
        let router = Teleroute()
        router.command("ping") { context in
            await recorder.record(context.update.updateId)
        }

        // A stub transport throws on ANY network call: start() in webhook mode
        // must not touch the network (beyond nothing at all).
        let bot = try TelerouteBot(
            token: TelerouteTestSupport.testToken,
            router: router,
            logger: .init(label: "tests.webhook-mode"),
            configuration: .init(replayProtectionStorage: nil),
            mode: .webhook,
            transport: TelerouteStubTransport(),
            rateLimit: nil
        )
        try await bot.start()
        await bot.process([
            TelerouteTestSupport.makeCommandUpdate(text: "/ping", updateId: 5_003),
        ])
        #expect(await recorder.waitForCount(1) == [5_003])
        await bot.shutdown()
    }

    @Test func newUpdatesAreRejectedAfterStopAccepting() async throws {
        let recorder = TelerouteTestRecorder<Int64>()
        let router = Teleroute()
        router.command("ping") { context in
            await recorder.record(context.update.updateId)
        }
        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        await bot.shutdown()
        await bot.process([
            TelerouteTestSupport.makeCommandUpdate(text: "/ping", updateId: 5_004),
        ])
        try await Task.sleep(for: .milliseconds(30))
        #expect(await recorder.values.isEmpty)
    }
}
