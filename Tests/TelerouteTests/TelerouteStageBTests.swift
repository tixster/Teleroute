import Testing
@testable import Teleroute
import TelerouteTestSupport
import SwiftTelegramBot
import Synchronization

@Suite(.serialized)
struct TelerouteStageBTests {
    @Test func groupScopedMiddlewareRunsBeforeRouteMiddleware() async throws {
        let bot = try await TelerouteTestSupport.makeBot(label: "router.group.middleware")
        let router = Teleroute(bot: bot, logger: .init(label: "router.group.middleware"))
        let recorder = TelerouteTestRecorder<[String]>()

        router.group("admin", middlewares: [RecordingMiddleware(recorder: recorder, label: "group")]) { admin in
            admin.command("ban", middlewares: [RecordingMiddleware(recorder: recorder, label: "route")]) { _ in
                await recorder.record(["handler"])
            }
        }

        await router.handle()
        await router.process([TelerouteTestSupport.makeCommandUpdate(text: "/admin_ban", updateId: 610)])

        let values = await recorder.waitForCount(5, retries: 100)
        #expect(values == [["group:before"], ["route:before"], ["handler"], ["route:after"], ["group:after"]])
    }

    @Test func groupScopedGuardRejectsChildRoute() async throws {
        let bot = try await TelerouteTestSupport.makeBot(label: "router.group.guard")
        let router = Teleroute(bot: bot, logger: .init(label: "router.group.guard"))
        let recorder = TelerouteTestRecorder<String>()

        router.group("admin", guards: [TelerouteChatTypeGuard(.group)]) { admin in
            admin.command("ban") { _ in
                await recorder.record("handled")
            }
        }

        await router.handle()
        await router.process([TelerouteTestSupport.makeCommandUpdate(text: "/admin_ban", chatType: .private, updateId: 611)])
        try? await Task.sleep(for: .milliseconds(30))
        #expect(await recorder.values.isEmpty)
    }

    @Test func retryMiddlewareReinvokesHandlerUntilSuccess() async throws {
        let bot = try await TelerouteTestSupport.makeBot(label: "router.retry")
        let attempts = Mutex(0)
        let router = Teleroute(bot: bot, logger: .init(label: "router.retry"))

        router.command(
            "flaky",
            middlewares: [TelerouteRetryMiddleware(retries: 2, backoff: { _ in .milliseconds(0) })]
        ) { _ in
            let count = attempts.withLock { $0 += 1; return $0 }
            if count < 3 {
                struct TransientError: Error {}
                throw TransientError()
            }
        }

        await router.handle()
        await router.process([TelerouteTestSupport.makeCommandUpdate(text: "/flaky", updateId: 612)])
        try? await Task.sleep(for: .milliseconds(30))

        #expect(attempts.withLock { $0 } == 3)
    }

    @Test func compiledMiddlewareCanInvokeDownstreamMoreThanOnce() async throws {
        let bot = try await TelerouteTestSupport.makeBot(label: "router.middleware.multiple-next")
        let recorder = TelerouteTestRecorder<String>()
        let router = Teleroute(
            bot: bot,
            logger: .init(label: "router.middleware.multiple-next"),
            configuration: .init(replayProtectionStorage: nil)
        )
        router.command("twice", middlewares: [CallNextTwiceMiddleware()]) { _ in
            await recorder.record("primary")
        }
        router.command("twice") { _ in
            await recorder.record("fallback")
        }

        await router.handle()
        await router.process([
            TelerouteTestSupport.makeCommandUpdate(text: "/twice", updateId: 619),
        ])

        #expect(await recorder.waitForCount(2) == ["primary", "primary"])
        router.shutdown()
    }

    @Test func timeoutMiddlewareThrowsWhenHandlerExceedsDeadline() async throws {
        let bot = try await TelerouteTestSupport.makeBot(label: "router.timeout")
        let sawTimeout = Mutex(false)

        let router = Teleroute(
            bot: bot,
            logger: .init(label: "router.timeout.onerror"),
            configuration: .init(onError: { error, _ in
                if error is TelerouteTimeoutError {
                    sawTimeout.withLock { $0 = true }
                }
            })
        )

        router.command(
            "slow",
            middlewares: [TelerouteTimeoutMiddleware(.milliseconds(20))]
        ) { _ in
            try? await Task.sleep(for: .milliseconds(200))
        }

        await router.handle()
        await router.process([TelerouteTestSupport.makeCommandUpdate(text: "/slow", updateId: 613)])
        try? await Task.sleep(for: .milliseconds(60))

        #expect(sawTimeout.withLock { $0 })
    }

    @Test func privateChatGuardPassesOnlyForPrivateChats() async throws {
        let bot = try await TelerouteTestSupport.makeBot(label: "router.guard.private")
        let router = Teleroute(bot: bot, logger: .init(label: "router.guard.private"))
        let recorder = TelerouteTestRecorder<String>()

        router.command("dm", guards: [TeleroutePrivateChatGuard()]) { _ in
            await recorder.record("dm")
        }

        await router.handle()
        await router.process([TelerouteTestSupport.makeCommandUpdate(text: "/dm", chatType: .group, chatId: 50, updateId: 614)])
        await router.process([TelerouteTestSupport.makeCommandUpdate(text: "/dm", chatType: .private, chatId: 51, updateId: 615)])

        let values = await recorder.waitForCount(1, retries: 200)
        #expect(values == ["dm"])
    }

    @Test func userAllowlistGuardRestrictsToKnownUsers() async throws {
        let bot = try await TelerouteTestSupport.makeBot(label: "router.guard.allowlist")
        let router = Teleroute(bot: bot, logger: .init(label: "router.guard.allowlist"))
        let recorder = TelerouteTestRecorder<Int64>()

        router.command("vip", guards: [TelerouteUserAllowlistGuard([42, 99])]) { context in
            if let userId = context.userId {
                await recorder.record(userId)
            }
        }

        await router.handle()
        await router.process([TelerouteTestSupport.makeCommandUpdate(text: "/vip", userId: 1, chatId: 60, updateId: 616)])
        await router.process([TelerouteTestSupport.makeCommandUpdate(text: "/vip", userId: 42, chatId: 61, updateId: 617)])

        let values = await recorder.waitForCount(1, retries: 200)
        #expect(values == [42])
    }

    @Test func errorHandlingMiddlewareConvertsErrorIntoReply() async throws {
        struct BoomError: Error {}
        let bot = try await TelerouteTestSupport.makeBot(label: "router.error-mw")
        let recorder = TelerouteTestRecorder<String>()

        let router = Teleroute(
            bot: bot,
            logger: .init(label: "router.error-mw"),
            configuration: .init(onError: { error, _ in
                await recorder.record("onError:\(error)")
            })
        )

        router.command(
            "boom",
            middlewares: [
                TelerouteErrorHandlingMiddleware { error, _ in
                    await recorder.record("handled:\(error)")
                }
            ]
        ) { _ in
            throw BoomError()
        }

        await router.handle()
        await router.process([TelerouteTestSupport.makeCommandUpdate(text: "/boom", updateId: 618)])

        let values = await recorder.waitForCount(1, retries: 100)
        #expect(values.first?.hasPrefix("handled:") == true)
        #expect(values.contains(where: { $0.hasPrefix("onError:") }) == false)
    }
}

private struct RecordingMiddleware: TelerouteMiddleware {
    let recorder: TelerouteTestRecorder<[String]>
    let label: String
    func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) async throws {
        await self.recorder.record(["\(self.label):before"])
        try await next(context)
        await self.recorder.record(["\(self.label):after"])
    }
}

private struct CallNextTwiceMiddleware: TelerouteMiddleware {
    func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) async throws {
        try await next(context)
        try await next(context)
    }
}
