import Foundation
import Synchronization
import Testing
import TelerouteTestSupport
@_spi(Testing) @testable import Teleroute

/// Tests for awaiting and observing channel posts that Telegram automatically
/// forwards into the channel's linked discussion chat.
@Suite struct TelerouteDiscussionForwardTests {
    static let channelId: Int64 = -1_001_378_178_515
    static let discussionChatId: Int64 = -1_001_220_561_176
    static let otherChatId: Int64 = -1_009_999_999_999

    // MARK: - Awaiting

    @Test func waitStartedBeforeTheForwardIsResumedByIt() async throws {
        let (bot, _) = try Self.makeBot()
        let tracker = try #require(bot.runtime.discussionForwards)

        let waiting = Task {
            try await bot.discussionMessage(channelId: Self.channelId, messageId: 42)
        }
        #expect(await Self.waitUntil { tracker.waiterCount == 1 })

        try await bot.test { client in
            _ = await client.execute(Self.forward(channelMessageId: 42, discussionMessageId: 555))
        }

        let forward = try #require(try await waiting.value)
        #expect(forward.channelId == Self.channelId)
        #expect(forward.channelMessageId == 42)
        #expect(forward.discussionChatId == Self.discussionChatId)
        #expect(forward.discussionMessageId == 555)
        #expect(tracker.waiterCount == 0)
        await bot.shutdown()
    }

    @Test func forwardThatArrivedFirstIsFoundInTheBuffer() async throws {
        let (bot, _) = try Self.makeBot()
        try await bot.test { client in
            _ = await client.execute(Self.forward(channelMessageId: 43, discussionMessageId: 556))
        }

        let post = Message(
            messageId: 43,
            date: 1,
            chat: Chat(id: Self.channelId, type: .channel, title: "Channel")
        )
        let forward = try await bot.discussionMessage(for: post, timeout: .milliseconds(50))
        #expect(forward?.discussionMessageId == 556)
        await bot.shutdown()
    }

    @Test func commandShapedPostIsTrackedAndObservedWhileTheCommandStillRuns() async throws {
        let seen = TelerouteTestRecorder<String>()
        let router = Teleroute()
        router.command("ping") { (_: TelerouteContext) -> Void in
            await seen.record("command")
        }
        router.onDiscussionForward { forward, _ in
            await seen.record("observer:\(forward.channelMessageId)")
        }
        let (bot, _) = try Self.makeBot(router: router)

        try await bot.test { client in
            let result = await client.execute(
                Self.forward(channelMessageId: 44, discussionMessageId: 557, text: "/ping")
            )
            #expect(result.terminalEvent?.kind == .handled)
        }

        #expect(await seen.values == ["observer:44", "command"])
        let forward = try await bot.discussionMessage(
            channelId: Self.channelId,
            messageId: 44,
            timeout: .milliseconds(50)
        )
        #expect(forward?.discussionMessageId == 557)
        await bot.shutdown()
    }

    @Test func twoPostsWithTheSameCommandTextAreBothTracked() async throws {
        let router = Teleroute()
        router.command("ping") { (_: TelerouteContext) -> Void in }
        // Replay protection on: both forwards come from the same service
        // account in the same chat, so it would drop the second one.
        let (bot, _) = try Self.makeBot(
            router: router,
            configuration: .init(discussionForwards: .enabled())
        )

        try await bot.test { client in
            _ = await client.execute(
                Self.forward(channelMessageId: 45, discussionMessageId: 600, text: "/ping", updateId: 1)
            )
            _ = await client.execute(
                Self.forward(channelMessageId: 46, discussionMessageId: 601, text: "/ping", updateId: 2)
            )
        }

        for (post, discussion) in [(Int64(45), Int64(600)), (46, 601)] {
            let forward = try await bot.discussionMessage(
                channelId: Self.channelId,
                messageId: post,
                timeout: .milliseconds(50)
            )
            #expect(forward?.discussionMessageId == discussion)
        }
        await bot.shutdown()
    }

    @Test func channelWithoutLinkedChatReturnsNilAndIsCached() async throws {
        let getChatCalls = Mutex(0)
        let fallback = TelerouteTestSupport.linkedChatFallback([Self.channelId: nil])
        let (bot, _) = try Self.makeBot { operationID, body in
            if operationID == "getChat" {
                getChatCalls.withLock { $0 += 1 }
            }
            return try fallback(operationID, body)
        }

        let clock = ContinuousClock()
        let started = clock.now
        let first = try await bot.discussionMessage(channelId: Self.channelId, messageId: 1)
        let second = try await bot.discussionMessage(channelId: Self.channelId, messageId: 2)

        #expect(first == nil)
        #expect(second == nil)
        // Neither call sat out its 20-second default timeout.
        #expect(started.duration(to: clock.now) < .seconds(10))
        #expect(getChatCalls.withLock { $0 } == 1)
        await bot.shutdown()
    }

    @Test func forwardIntoAnotherChatIsIgnored() async throws {
        let (bot, _) = try Self.makeBot()
        try await bot.test { client in
            _ = await client.execute(
                TelerouteTestSupport.makeAutomaticForwardUpdate(
                    channelId: Self.channelId,
                    channelMessageId: 47,
                    discussionChatId: Self.otherChatId
                )
            )
        }

        await #expect(throws: TelerouteDiscussionForwardError.timeout(
            channelId: Self.channelId,
            channelMessageId: 47,
            discussionChatId: Self.discussionChatId
        )) {
            try await bot.discussionMessage(channelId: Self.channelId, messageId: 47, timeout: .milliseconds(50))
        }
        await bot.shutdown()
    }

    @Test func manualForwardIsNeitherTrackedNorObserved() async throws {
        let observed = TelerouteTestRecorder<Int64>()
        let router = Teleroute()
        router.onDiscussionForward { forward, _ in
            await observed.record(forward.channelMessageId)
        }
        let (bot, _) = try Self.makeBot(router: router)
        let tracker = try #require(bot.runtime.discussionForwards)

        var update = Self.forward(channelMessageId: 48, discussionMessageId: 558)
        update.message?.isAutomaticForward = nil
        try await bot.test { client in
            _ = await client.execute(update)
        }

        #expect(await observed.values.isEmpty)
        #expect(tracker.count == 0)
        await bot.shutdown()
    }

    @Test func waitingTimesOut() async throws {
        let (bot, _) = try Self.makeBot()
        let tracker = try #require(bot.runtime.discussionForwards)

        await #expect(throws: TelerouteDiscussionForwardError.timeout(
            channelId: Self.channelId,
            channelMessageId: 49,
            discussionChatId: Self.discussionChatId
        )) {
            try await bot.discussionMessage(channelId: Self.channelId, messageId: 49, timeout: .milliseconds(20))
        }
        #expect(tracker.waiterCount == 0)
        await bot.shutdown()
    }

    @Test func cancellingTheWaiterThrowsCancellationError() async throws {
        let (bot, _) = try Self.makeBot()
        let tracker = try #require(bot.runtime.discussionForwards)

        let waiting = Task {
            try await bot.discussionMessage(channelId: Self.channelId, messageId: 50)
        }
        #expect(await Self.waitUntil { tracker.waiterCount == 1 })
        waiting.cancel()

        await #expect(throws: CancellationError.self) {
            try await waiting.value
        }
        #expect(tracker.waiterCount == 0)
        await bot.shutdown()
    }

    @Test func shutdownResumesWaitersAndRejectsNewOnes() async throws {
        let (bot, _) = try Self.makeBot()
        let tracker = try #require(bot.runtime.discussionForwards)

        let waiting = Task {
            try await bot.discussionMessage(channelId: Self.channelId, messageId: 51)
        }
        #expect(await Self.waitUntil { tracker.waiterCount == 1 })
        await bot.shutdown()

        await #expect(throws: TelerouteDiscussionForwardError.shutdown) {
            try await waiting.value
        }
        await #expect(throws: TelerouteDiscussionForwardError.shutdown) {
            try await bot.discussionMessage(channelId: Self.channelId, messageId: 52)
        }
    }

    @Test func nonChannelPostIsRejected() async throws {
        let (bot, _) = try Self.makeBot()
        let message = Message(messageId: 1, date: 1, chat: Chat(id: 7, type: .private))

        await #expect(throws: TelerouteDiscussionForwardError.notAChannelPost(chatId: 7)) {
            try await bot.discussionMessage(for: message)
        }
        await bot.shutdown()
    }

    @Test func routeHandlerCanAwaitThroughItsContext() async throws {
        let found = TelerouteTestRecorder<Int64>()
        let router = Teleroute()
        router.command("comment") { (context: TelerouteContext) -> Void in
            let forward = try await context.discussionMessage(
                channelId: Self.channelId,
                messageId: 53,
                timeout: .milliseconds(50)
            )
            await found.record(forward?.discussionMessageId ?? -1)
        }
        let (bot, _) = try Self.makeBot(router: router)

        try await bot.test { client in
            _ = await client.execute(Self.forward(channelMessageId: 53, discussionMessageId: 559, updateId: 1))
            let result = await client.execute(
                TelerouteTestSupport.makeCommandUpdate(text: "/comment", updateId: 2)
            )
            #expect(result.terminalEvent?.kind == .handled)
        }
        #expect(await found.values == [559])
        await bot.shutdown()
    }

    // MARK: - Send and wait

    @Test func sendWithDiscussionForwardReturnsThePostAndItsForward() async throws {
        let (bot, _) = try Self.makeBot()
        let tracker = try #require(bot.runtime.discussionForwards)

        let sending = Task {
            try await bot.sendWithDiscussionForward { _ in Self.channelPost(messageId: 60) }
        }
        #expect(await Self.waitUntil { tracker.waiterCount == 1 })
        try await bot.test { client in
            _ = await client.execute(Self.forward(channelMessageId: 60, discussionMessageId: 600))
        }

        let (post, forward) = try await sending.value
        #expect(post.messageId == 60)
        #expect(forward?.discussionMessageId == 600)
        await bot.shutdown()
    }

    @Test func sendWithDiscussionForwardKeepsThePostWhenWaitingFails() async throws {
        let (bot, _) = try Self.makeBot()

        do {
            _ = try await bot.sendWithDiscussionForward(timeout: .milliseconds(20)) { _ in
                Self.channelPost(messageId: 61)
            }
            Issue.record("expected a TelerouteDiscussionPostError")
        } catch let error as TelerouteDiscussionPostError {
            #expect(error.post.messageId == 61)
            #expect(error.underlying as? TelerouteDiscussionForwardError == .timeout(
                channelId: Self.channelId,
                channelMessageId: 61,
                discussionChatId: Self.discussionChatId
            ))
        }
        await bot.shutdown()
    }

    @Test func sendWithDiscussionForwardPassesSendErrorsThrough() async throws {
        struct SendFailure: Error {}
        let (bot, _) = try Self.makeBot()

        await #expect(throws: SendFailure.self) {
            try await bot.sendWithDiscussionForward { _ in throw SendFailure() }
        }
        await bot.shutdown()
    }

    @Test func sendWithDiscussionForwardSendsNothingWhenTrackingIsOff() async throws {
        let sent = Mutex(false)
        let (bot, _) = try Self.makeBot(
            configuration: .init(replayProtectionStorage: nil, discussionForwards: .disabled)
        )

        await #expect(throws: TelerouteDiscussionForwardError.trackingDisabled) {
            try await bot.sendWithDiscussionForward { _ in
                sent.withLock { $0 = true }
                return Self.channelPost(messageId: 62)
            }
        }
        #expect(sent.withLock { $0 } == false)
        await bot.shutdown()
    }

    @Test func routeHandlerCanSendAndWaitThroughItsContext() async throws {
        let found = TelerouteTestRecorder<Int64>()
        let router = Teleroute()
        router.command("publish") { (context: TelerouteContext) -> Void in
            let (_, forward) = try await context.sendWithDiscussionForward(timeout: .milliseconds(50)) { _ in
                Self.channelPost(messageId: 63)
            }
            await found.record(forward?.discussionMessageId ?? -1)
        }
        let (bot, _) = try Self.makeBot(router: router)

        try await bot.test { client in
            _ = await client.execute(Self.forward(channelMessageId: 63, discussionMessageId: 630, updateId: 1))
            _ = await client.execute(TelerouteTestSupport.makeCommandUpdate(text: "/publish", updateId: 2))
        }
        #expect(await found.values == [630])
        await bot.shutdown()
    }

    // MARK: - Disabled policy

    @Test func disabledPolicyRejectsWaitingButStillRunsObservers() async throws {
        let observed = TelerouteTestRecorder<Int64>()
        let router = Teleroute()
        router.onDiscussionForward { forward, _ in
            await observed.record(forward.discussionMessageId)
        }
        let (bot, _) = try Self.makeBot(
            router: router,
            configuration: .init(replayProtectionStorage: nil, discussionForwards: .disabled)
        )
        #expect(bot.runtime.discussionForwards == nil)

        try await bot.test { client in
            _ = await client.execute(Self.forward(channelMessageId: 54, discussionMessageId: 560))
        }
        #expect(await observed.values == [560])

        await #expect(throws: TelerouteDiscussionForwardError.trackingDisabled) {
            try await bot.discussionMessage(channelId: Self.channelId, messageId: 54)
        }
        let directContext = TelerouteContext(
            bot: bot.client,
            update: TelerouteTestSupport.makeMessageUpdate(text: "hi")
        )
        await #expect(throws: TelerouteDiscussionForwardError.trackingDisabled) {
            try await directContext.discussionMessage(channelId: Self.channelId, messageId: 54)
        }
        await bot.shutdown()
    }

    // MARK: - Observers

    @Test func failingObserverReportsToOnErrorWithoutBlockingRouting() async throws {
        struct ObserverFailure: Error {}
        let errors = TelerouteTestRecorder<String>()
        let handled = TelerouteTestRecorder<String>()
        let router = Teleroute()
        router.onDiscussionForward { _, _ in
            throw ObserverFailure()
        }
        router.message { (_: TelerouteContext) -> Void in
            await handled.record("message")
        }
        let (bot, _) = try Self.makeBot(
            router: router,
            configuration: .init(
                replayProtectionStorage: nil,
                onError: { error, _ in await errors.record(String(describing: type(of: error))) },
                discussionForwards: .enabled()
            )
        )

        try await bot.test { client in
            let result = await client.execute(Self.forward(channelMessageId: 55, discussionMessageId: 561))
            #expect(result.terminalEvent?.kind == .handled)
        }
        #expect(await errors.values == ["ObserverFailure"])
        #expect(await handled.values == ["message"])
        await bot.shutdown()
    }

    @Test func observerInChildContextGroupReceivesTheChildContext() async throws {
        struct Child: TelerouteChildRequestContext {
            let coreContext: TelerouteContext
            let tag: String
            init(context: TelerouteContext) async throws {
                self.coreContext = context
                self.tag = "child"
            }
        }
        let seen = TelerouteTestRecorder<String>()
        let router = Teleroute()
        router.group(context: Child.self).onDiscussionForward { forward, context in
            await seen.record("\(context.tag):\(forward.channelMessageId)")
        }
        let (bot, _) = try Self.makeBot(router: router)

        try await bot.test { client in
            _ = await client.execute(Self.forward(channelMessageId: 56, discussionMessageId: 562))
        }
        #expect(await seen.values == ["child:56"])
        await bot.shutdown()
    }

    // MARK: - allowed_updates

    @Test func trackingIsOnByDefault() throws {
        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(router: Teleroute())
        #expect(bot.runtime.discussionForwards != nil)
    }

    @Test func onlyObserversAskForMessages() throws {
        // Tracking is on by default, so it must not widen the request.
        let callbacksOnly = Teleroute()
        callbacksOnly.callback("tap") { (_: TelerouteContext) -> Void in }
        let (tracked, _) = try TelerouteTestSupport.makeTelerouteBot(router: callbacksOnly)
        #expect(tracked.runtime.discussionForwards != nil)
        #expect(tracked.resolvedAllowedUpdates() == ["callback_query"])

        let observing = Teleroute()
        observing.onDiscussionForward { _, _ in }
        let (observed, _) = try TelerouteTestSupport.makeTelerouteBot(router: observing)
        #expect(observed.resolvedAllowedUpdates() == ["message"])
    }

    @Test func waitingWithoutMessageUpdatesWarnsOnce() async throws {
        let callbacksOnly = Teleroute()
        callbacksOnly.callback("tap") { (_: TelerouteContext) -> Void in }
        let (bot, logs) = try Self.makeBotCapturingLogs(router: callbacksOnly)

        for messageId in Int64(1)...2 {
            _ = try? await bot.discussionMessage(
                channelId: Self.channelId,
                messageId: messageId,
                timeout: .milliseconds(10)
            )
        }
        let warnings = logs.all.filter { $0.level == .warning && $0.message.contains("allowed_updates") }
        #expect(warnings.count == 1)
        await bot.shutdown()
    }

    @Test func waitingWithMessageUpdatesDoesNotWarn() async throws {
        let router = Teleroute()
        router.command("start") { (_: TelerouteContext) -> Void in }
        let (bot, logs) = try Self.makeBotCapturingLogs(router: router)

        _ = try? await bot.discussionMessage(
            channelId: Self.channelId,
            messageId: 1,
            timeout: .milliseconds(10)
        )
        #expect(logs.all.contains { $0.message.contains("allowed_updates") } == false)
        await bot.shutdown()
    }

    // MARK: - Tracker

    @Test func trackerEvictsTheOldestForwardsBeyondCapacity() async throws {
        let tracker = TelerouteDiscussionForwardTracker(
            retention: .seconds(60),
            capacity: 2,
            linkedChatCacheTTL: .seconds(60)
        )
        for id in Int64(1)...3 {
            tracker.record(try Self.discussionForward(channelMessageId: id, discussionMessageId: 100 + id))
        }
        #expect(tracker.count == 2)

        let newest = try await tracker.wait(
            for: .init(channelId: Self.channelId, channelMessageId: 3),
            discussionChatId: Self.discussionChatId,
            timeout: .milliseconds(20)
        )
        #expect(newest.discussionMessageId == 103)
        await #expect(throws: TelerouteDiscussionForwardError.self) {
            try await tracker.wait(
                for: .init(channelId: Self.channelId, channelMessageId: 1),
                discussionChatId: Self.discussionChatId,
                timeout: .milliseconds(20)
            )
        }
    }

    @Test func trackerDropsForwardsOlderThanTheRetention() throws {
        let tracker = TelerouteDiscussionForwardTracker(
            retention: .seconds(1),
            capacity: 10,
            linkedChatCacheTTL: .seconds(60)
        )
        let start = ContinuousClock.now
        tracker.record(try Self.discussionForward(channelMessageId: 1, discussionMessageId: 1), now: start)
        tracker.record(
            try Self.discussionForward(channelMessageId: 2, discussionMessageId: 2),
            now: start.advanced(by: .seconds(2))
        )
        #expect(tracker.count == 1)
    }

    // MARK: - Helpers

    private static func makeBot(
        router: Teleroute<TelerouteContext> = Teleroute(),
        configuration: TelerouteBot.Configuration = .init(
            replayProtectionStorage: nil,
            discussionForwards: .enabled()
        ),
        fallback: TelerouteRecordingTransport.Fallback? = nil
    ) throws -> (TelerouteBot, TelerouteRecordingTransport) {
        let telegram = TelerouteRecordingTransport(
            fallback: fallback ?? TelerouteTestSupport.linkedChatFallback([
                Self.channelId: Self.discussionChatId,
            ])
        )
        let bot = try TelerouteBot(
            token: TelerouteTestSupport.testToken,
            router: router,
            configuration: configuration,
            mode: .manual,
            transport: telegram,
            rateLimit: nil
        )
        return (bot, telegram)
    }

    private static func makeBotCapturingLogs(
        router: Teleroute<TelerouteContext>
    ) throws -> (TelerouteBot, TelerouteTestLogStore) {
        let logs = TelerouteTestLogStore()
        let bot = try TelerouteBot(
            token: TelerouteTestSupport.testToken,
            router: router,
            logger: Logger(label: "teleroute.tests.discussion") { _ in TelerouteTestLogHandler(store: logs) },
            configuration: .init(replayProtectionStorage: nil),
            mode: .manual,
            transport: TelerouteRecordingTransport(
                fallback: TelerouteTestSupport.linkedChatFallback([Self.channelId: Self.discussionChatId])
            ),
            rateLimit: nil
        )
        return (bot, logs)
    }

    private static func makeBot(
        fallback: @escaping TelerouteRecordingTransport.Fallback
    ) throws -> (TelerouteBot, TelerouteRecordingTransport) {
        try self.makeBot(router: Teleroute(), fallback: fallback)
    }

    private static func forward(
        channelMessageId: Int64,
        discussionMessageId: Int64,
        text: String = "Chapter 69",
        updateId: Int64 = 20
    ) -> Update {
        TelerouteTestSupport.makeAutomaticForwardUpdate(
            channelId: self.channelId,
            channelMessageId: channelMessageId,
            discussionChatId: self.discussionChatId,
            discussionMessageId: discussionMessageId,
            text: text,
            updateId: updateId
        )
    }

    private static func channelPost(messageId: Int64) -> Message {
        Message(
            messageId: messageId,
            date: 1,
            chat: Chat(id: self.channelId, type: .channel, title: "Channel")
        )
    }

    private static func discussionForward(
        channelMessageId: Int64,
        discussionMessageId: Int64
    ) throws -> TelerouteDiscussionForward {
        let message = try #require(
            self.forward(channelMessageId: channelMessageId, discussionMessageId: discussionMessageId).message
        )
        return try #require(TelerouteDiscussionForward(message))
    }

    private static func waitUntil(
        retries: Int = 200,
        _ condition: () -> Bool
    ) async -> Bool {
        for _ in 0..<retries {
            if condition() { return true }
            try? await Task.sleep(for: .milliseconds(5))
        }
        return condition()
    }
}
