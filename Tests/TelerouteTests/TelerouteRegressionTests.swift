import Testing
@_spi(Testing) @testable import Teleroute
import TelerouteTestSupport

@Suite(.serialized)
struct TelerouteRegressionTests {
    @Test func flowMountedInGuardedGroupHonorsInheritedGuard() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let storage = TelerouteInMemoryFlowStorage()
        let recorder = RegressionRecorder<String>()
        let router = TelerouteRuntime(
            bot: bot,
            logger: .init(label: "regression.flow.guard"),
            configuration: .init(
                flowStorage: storage,
                replayProtectionStorage: nil
            )
        )

        router.group("secure", guards: [RegressionDenyGuard()]) { group in
            group.flow(RegressionStartFlow(recorder: recorder))
        }

        await router.handle()
        await router.process([
            TelerouteTestSupport.makeCommandUpdate(
                text: "/secure_begin",
                chatId: 100,
                updateId: 1_000
            ),
        ])
        #expect(await eventually { router.processingTaskCount == 0 })

        let key = TelerouteFlowKey(chatId: 100, userId: 1)
        #expect(await recorder.values.isEmpty)
        #expect(await storage.session(for: key) == nil)
        router.shutdown()
    }

    @Test func flowMountedInGroupRunsInheritedMiddleware() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let recorder = RegressionRecorder<String>()
        let router = TelerouteRuntime(bot: bot, logger: .init(label: "regression.flow.middleware"))

        router.group(
            "observed",
            middlewares: [RegressionRecordingMiddleware(recorder: recorder, label: "group")]
        ) { group in
            group.flow(RegressionStartFlow(recorder: recorder))
        }

        await router.handle()
        await router.process([
            TelerouteTestSupport.makeCommandUpdate(text: "/observed_begin", updateId: 1_001),
        ])

        #expect(await recorder.waitForCount(3) == ["group:before", "handler", "group:after"])
        router.shutdown()
    }

    @Test func sequentialFlowUpdatesMergeAgainstLatestStoredSession() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let storage = TelerouteInMemoryFlowStorage()
        let recorder = RegressionRecorder<String>()
        let router = TelerouteRuntime(
            bot: bot,
            logger: .init(label: "regression.flow.atomic-update"),
            configuration: .init(
                flowStorage: storage,
                replayProtectionStorage: nil
            )
        )
        router.flow(RegressionAtomicFlow(recorder: recorder))

        await router.handle()
        await router.process([
            TelerouteTestSupport.makeCommandUpdate(text: "/atomic", chatId: 101, updateId: 1_002),
        ])
        _ = await recorder.waitForCount(1)
        await router.process([
            TelerouteTestSupport.makeMessageUpdate(text: "values", chatId: 101, updateId: 1_003),
        ])
        _ = await recorder.waitForCount(2)

        let session = await storage.session(for: .init(chatId: 101, userId: 1))
        #expect(session?.values["first"] == "one")
        #expect(session?.values["second"] == "two")
        #expect(session?.step == RegressionAtomicFlow.Step.next.rawValue)
        router.shutdown()
    }

    @Test func inheritedGuardExcludesDuplicatesAndStaysAheadOfQueueMiddleware() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let router = TelerouteRuntime(bot: bot, logger: .init(label: "regression.group.queue-order"))

        router.group("guarded", guards: [RegressionAllowGuard()]) { group in
            group.command("same", queue: .perChatAndUser) { _ in }
            group.command("same") { _ in }
        }

        #expect(router.duplicateRouteSignatures.isEmpty)
        let middlewares = try #require(
            router.storage.routeGraph.commandsByName["guarded_same"]?.first?.middlewares
        )
        #expect(middlewares.count >= 2)
        #expect(middlewares[0] is TelerouteGuardMiddleware)
        #expect(middlewares[1] is TelerouteCommandQueueMiddleware)
        router.shutdown()
    }

    @Test func debounceRethrowsCancellationFromDownstreamHandler() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let context = TelerouteContext(
            bot: bot,
            update: TelerouteTestSupport.makeCommandUpdate(text: "/debounce", updateId: 1_004),
            command: .init(
                name: "debounce",
                rawValue: "/debounce",
                mentionedBotUsername: nil,
                argumentsText: nil,
                arguments: []
            )
        )
        let middleware = TelerouteDebounceMiddleware(interval: .zero, scope: .command)

        await #expect(throws: CancellationError.self) {
            try await middleware.handle(context) { _ in
                throw CancellationError()
            }
        }
    }

    @Test func failedCallbackPreservesMatchedParametersAndRouteName() async throws {
        struct CallbackFailure: Error {}

        let bot = try await TelerouteTestSupport.makeBot()
        let errors = RegressionRecorder<RegressionErrorObservation>()
        let router = TelerouteRuntime(
            bot: bot,
            logger: .init(label: "regression.error.callback"),
            configuration: .init(onError: { _, context in
                await errors.record(
                    .init(
                        parameter: context.parameters["id"],
                        flowID: context.activeFlow?.id
                    )
                )
            })
        )
        let events = router.eventStream()
        let failedEvent = Task<TelerouteEvent?, Never> {
            for await event in events where event.kind == .failed {
                return event
            }
            return nil
        }

        router.callback("orders/{id}") { _ in
            throw CallbackFailure()
        }
        await router.handle()
        await router.process([
            TelerouteTestSupport.makeCallbackUpdate(data: "orders/42", updateId: 1_005),
        ])

        let event = await failedEvent.value
        #expect(await errors.waitForCount(1).first?.parameter == "42")
        #expect(event?.routeKind == .callback)
        #expect(event?.routeName == "orders/{id}")
        #expect(event?.error is CallbackFailure)
        router.shutdown()
    }

    @Test func failedFlowPreservesFlowContextForEventsMetricsAndOnError() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let starts = RegressionRecorder<String>()
        let errors = RegressionRecorder<RegressionErrorObservation>()
        let metrics = RegressionMetricsSink()
        let router = TelerouteRuntime(
            bot: bot,
            logger: .init(label: "regression.error.flow"),
            configuration: .init(
                metricsSink: metrics,
                onError: { _, context in
                    await errors.record(
                        .init(
                            parameter: nil,
                            flowID: context.activeFlow?.id
                        )
                    )
                }
            )
        )
        let events = router.eventStream()
        let failedEvent = Task<TelerouteEvent?, Never> {
            for await event in events where event.kind == .failed {
                return event
            }
            return nil
        }
        router.flow(RegressionFailingFlow(recorder: starts))

        await router.handle()
        await router.process([
            TelerouteTestSupport.makeCommandUpdate(text: "/failing", updateId: 1_006),
        ])
        _ = await starts.waitForCount(1)
        await router.process([
            TelerouteTestSupport.makeMessageUpdate(text: "boom", updateId: 1_007),
        ])

        let event = await failedEvent.value
        let expectedName = "\(RegressionFailingFlow.id):active"
        #expect(event?.routeKind == .flow)
        #expect(event?.routeName == expectedName)
        #expect(await errors.waitForCount(1).first?.flowID == RegressionFailingFlow.id)
        #expect(await metrics.waitForFailure()?.routeName == expectedName)
        router.shutdown()
    }

    @Test func eventHubRemovesCancelledSubscribers() async {
        let hub = TelerouteEventHub()
        let sequence = hub.sequence(buffering: .unbounded)
        let consumer = Task {
            for await _ in sequence {}
        }

        #expect(await eventually { hub.subscriberCount == 1 })
        consumer.cancel()
        await consumer.value
        #expect(await eventually { hub.subscriberCount == 0 })
        hub.finish()
    }

    @Test func eventHubHonorsBoundedNewestBufferAndFinishesLateSubscribers() async {
        let hub = TelerouteEventHub()
        let sequence = hub.sequence(buffering: .newest(2))
        hub.emit(regressionEvent(updateID: 1))
        hub.emit(regressionEvent(updateID: 2))
        hub.emit(regressionEvent(updateID: 3))

        var iterator = sequence.makeAsyncIterator()
        #expect(await iterator.next()?.updateId == 2)
        #expect(await iterator.next()?.updateId == 3)
        hub.finish()
        #expect(await iterator.next() == nil)

        var lateIterator = hub.sequence(buffering: .unbounded).makeAsyncIterator()
        #expect(await lateIterator.next() == nil)
        #expect(hub.subscriberCount == 0)
    }

    @Test func shutdownCancelsInFlightHandlersWithoutFailedEvent() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let probe = RegressionShutdownProbe()
        let router = TelerouteRuntime(
            bot: bot,
            logger: .init(label: "regression.shutdown"),
            configuration: .init(replayProtectionStorage: nil)
        )
        let events = router.eventStream()
        let eventCollector = Task {
            var collected: [TelerouteEvent] = []
            for await event in events {
                collected.append(event)
            }
            return collected
        }
        router.command("wait") { _ in
            await probe.started()
            do {
                try await Task.sleep(for: .seconds(30))
            } catch is CancellationError {
                await probe.cancelled()
                throw CancellationError()
            }
        }

        await router.handle()
        await router.process([
            TelerouteTestSupport.makeCommandUpdate(text: "/wait", updateId: 1_008),
        ])
        #expect(await eventually { await probe.startCount == 1 })

        router.shutdown()
        #expect(await eventually { await probe.cancelCount == 1 })
        #expect(router.processingTaskCount == 0)
        #expect(await eventCollector.value.contains { $0.kind == .failed } == false)

        await router.process([
            TelerouteTestSupport.makeCommandUpdate(text: "/wait", updateId: 1_009),
        ])
        #expect(await probe.startCount == 1)
    }

    @Test func shutdownResumesProducerWaitingForExecutorCapacity() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let probe = RegressionShutdownProbe()
        let router = TelerouteRuntime(
            bot: bot,
            logger: .init(label: "regression.shutdown.backpressure"),
            configuration: .init(
                replayProtectionStorage: nil,
                maximumConcurrentUpdates: 1
            )
        )
        router.command("wait") { _ in
            await probe.started()
            do {
                try await Task.sleep(for: .seconds(30))
            } catch is CancellationError {
                await probe.cancelled()
                throw CancellationError()
            }
        }
        await router.handle()

        let processing = Task {
            await router.process((0..<3).map { value in
                TelerouteTestSupport.makeCommandUpdate(
                    text: "/wait",
                    updateId: 1_100 + value
                )
            })
        }
        #expect(await eventually { await probe.startCount == 1 })

        router.shutdown()
        await processing.value
        #expect(await eventually { await probe.cancelCount == 1 })
        #expect(router.processingTaskCount == 0)
    }

    @Test func completedProcessingTasksAreRemovedFromExecutor() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let recorder = RegressionRecorder<Int>()
        let router = TelerouteRuntime(
            bot: bot,
            logger: .init(label: "regression.update-executor"),
            configuration: .init(replayProtectionStorage: nil)
        )
        router.command("fast") { context in
            await recorder.record(Int(context.command?.arguments.first ?? "") ?? -1)
        }
        await router.handle()

        let updates = (0..<200).map { value in
            TelerouteTestSupport.makeCommandUpdate(
                text: "/fast \(value)",
                updateId: 2_000 + value
            )
        }
        await router.process(updates)

        #expect(await recorder.waitForCount(updates.count, retries: 200).count == updates.count)
        #expect(await eventually(attempts: 200) { router.processingTaskCount == 0 })
        router.shutdown()
    }

    @Test func updateExecutorAppliesBackpressureAtConfiguredLimit() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let probe = RegressionConcurrencyProbe()
        let router = TelerouteRuntime(
            bot: bot,
            logger: .init(label: "regression.executor.limit"),
            configuration: .init(
                replayProtectionStorage: nil,
                maximumConcurrentUpdates: 2
            )
        )
        router.command("bounded") { _ in
            await probe.enterAndWait()
            await probe.leave()
        }
        await router.handle()

        let updates = (0..<6).map { value in
            TelerouteTestSupport.makeCommandUpdate(
                text: "/bounded",
                updateId: 3_000 + value
            )
        }
        let processing = Task {
            await router.process(updates)
        }

        await probe.waitForStarts(2)
        #expect(await probe.peak == 2)
        #expect(router.processingTaskCount == 2)

        await probe.release()
        await processing.value
        await probe.waitForCompletions(updates.count)
        #expect(await probe.peak == 2)
        #expect(await eventually { router.processingTaskCount == 0 })
        router.shutdown()
    }

    @Test func callbackIndexPreservesWildcardAndLiteralRegistrationOrder() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let recorder = RegressionRecorder<String>()
        let router = TelerouteRuntime(
            bot: bot,
            logger: .init(label: "regression.callback-index.order"),
            configuration: .init(
                replayProtectionStorage: nil,
                maximumConcurrentUpdates: 1
            )
        )
        router.callback(
            "{section}/action",
            guards: [RegressionUpdateIDGuard(allowed: [3_100])]
        ) { context in
            await recorder.record("wildcard:\(context.update.updateId)")
        }
        router.callback("orders/action") { context in
            await recorder.record("literal:\(context.update.updateId)")
        }
        await router.handle()
        await router.process([
            TelerouteTestSupport.makeCallbackUpdate(data: "orders/action", updateId: 3_100),
            TelerouteTestSupport.makeCallbackUpdate(data: "orders/action", updateId: 3_101),
        ])

        #expect(
            await recorder.waitForCount(2) == ["wildcard:3100", "literal:3101"]
        )
        router.shutdown()
    }

    @Test func routerSkipsFlowStorageWhenNoFlowIsMounted() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let flowStorage = RegressionCountingFlowStorage()
        let recorder = RegressionRecorder<String>()
        let router = TelerouteRuntime(
            bot: bot,
            logger: .init(label: "regression.flow.fast-path"),
            configuration: .init(
                flowStorage: flowStorage,
                replayProtectionStorage: nil
            )
        )
        router.command("ping") { _ in
            await recorder.record("pong")
        }
        await router.handle()
        await router.process([
            TelerouteTestSupport.makeCommandUpdate(text: "/ping", updateId: 3_200),
        ])

        #expect(await recorder.waitForCount(1) == ["pong"])
        #expect(await flowStorage.sessionLookupCount == 0)
        router.shutdown()
    }

    @Test func queueRemovesIdleWorkerWithoutAnotherSubmission() async throws {
        let queue = TelerouteCommandQueue(workerIdleTimeout: .milliseconds(20))
        let value = try await queue.enqueue(key: "idle") { 42 }
        #expect(value == 42)
        #expect(await eventually(attempts: 200) { await queue.workerCount == 0 })
    }
}

private actor RegressionRecorder<Value: Sendable> {
    private var storage: [Value] = []

    func record(_ value: Value) {
        self.storage.append(value)
    }

    var values: [Value] {
        self.storage
    }

    func waitForCount(_ count: Int, retries: Int = 100) async -> [Value] {
        for _ in 0..<retries {
            if self.storage.count >= count {
                return self.storage
            }
            try? await Task.sleep(for: .milliseconds(5))
        }
        return self.storage
    }
}

private func eventually(
    attempts: Int = 100,
    _ condition: @escaping @Sendable () async -> Bool
) async -> Bool {
    for _ in 0..<attempts {
        if await condition() {
            return true
        }
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(2))
    }
    return await condition()
}

private struct RegressionDenyGuard: TelerouteGuard {
    func matches(_ context: TelerouteContext) async throws -> Bool { false }
}

private struct RegressionAllowGuard: TelerouteGuard {
    func matches(_ context: TelerouteContext) async throws -> Bool { true }
}

private struct RegressionUpdateIDGuard: TelerouteGuard {
    let allowed: Set<Int>

    func matches(_ context: TelerouteContext) async throws -> Bool {
        self.allowed.contains(context.update.updateId)
    }
}

private struct RegressionRecordingMiddleware: TelerouteMiddleware {
    let recorder: RegressionRecorder<String>
    let label: String

    func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) async throws {
        await self.recorder.record("\(self.label):before")
        try await next(context)
        await self.recorder.record("\(self.label):after")
    }
}

private struct RegressionStartFlow: TelerouteFlow {
    enum Step: String, Sendable {
        case active
    }

    static let id = "regression-start"
    let recorder: RegressionRecorder<String>

    func boot(flow: TelerouteFlowGroup<Self>) {
        flow.start("begin", at: .active) { _ in
            await self.recorder.record("handler")
        }
    }
}

private struct RegressionAtomicFlow: TelerouteFlow {
    enum Step: String, Sendable {
        case active
        case next
    }

    static let id = "regression-atomic"
    let recorder: RegressionRecorder<String>

    func boot(flow: TelerouteFlowGroup<Self>) {
        flow.start("atomic", at: .active) { _ in
            await self.recorder.record("started")
        }
        flow.message(at: .active) { context in
            try await context.transition(to: .next, merging: ["first": "one"])
            try await context.update(merging: ["second": "two"])
            await self.recorder.record("updated")
        }
    }
}

private enum RegressionFlowError: Error {
    case boom
}

private struct RegressionFailingFlow: TelerouteFlow {
    enum Step: String, Sendable {
        case active
    }

    static let id = "regression-failing"
    let recorder: RegressionRecorder<String>

    func boot(flow: TelerouteFlowGroup<Self>) {
        flow.start("failing", at: .active) { _ in
            await self.recorder.record("started")
        }
        flow.message(at: .active) { _ in
            throw RegressionFlowError.boom
        }
    }
}

private struct RegressionErrorObservation: Sendable {
    let parameter: String?
    let flowID: String?
}

private actor RegressionMetricsSink: TelerouteMetricsSink {
    struct Failure: Sendable {
        let routeKind: TelerouteEvent.RouteKind
        let routeName: String?
    }

    private var failures: [Failure] = []

    func recordFailed(
        routeKind: TelerouteEvent.RouteKind,
        routeName: String?,
        chatId: Int64?,
        userId: Int64?,
        duration: Duration,
        error: any Error
    ) async {
        self.failures.append(.init(routeKind: routeKind, routeName: routeName))
    }

    func waitForFailure() async -> Failure? {
        for _ in 0..<100 {
            if let failure = self.failures.first {
                return failure
            }
            try? await Task.sleep(for: .milliseconds(5))
        }
        return self.failures.first
    }
}

private actor RegressionShutdownProbe {
    private var starts = 0
    private var cancellations = 0

    func started() {
        self.starts += 1
    }

    func cancelled() {
        self.cancellations += 1
    }

    var startCount: Int { self.starts }
    var cancelCount: Int { self.cancellations }
}

private actor RegressionConcurrencyProbe {
    private var active = 0
    private var maximumActive = 0
    private var starts = 0
    private var completions = 0
    private var isReleased = false
    private var releaseWaiters: [CheckedContinuation<Void, Never>] = []
    private var startWaiters: [(Int, CheckedContinuation<Void, Never>)] = []
    private var completionWaiters: [(Int, CheckedContinuation<Void, Never>)] = []

    var peak: Int { self.maximumActive }

    func enterAndWait() async {
        self.active += 1
        self.starts += 1
        self.maximumActive = max(self.maximumActive, self.active)
        self.resumeSatisfiedWaiters()
        guard self.isReleased == false else { return }
        await withCheckedContinuation { continuation in
            self.releaseWaiters.append(continuation)
        }
    }

    func leave() {
        self.active -= 1
        self.completions += 1
        self.resumeSatisfiedWaiters()
    }

    func release() {
        self.isReleased = true
        let waiters = self.releaseWaiters
        self.releaseWaiters.removeAll()
        for waiter in waiters {
            waiter.resume()
        }
    }

    func waitForStarts(_ target: Int) async {
        guard self.starts < target else { return }
        await withCheckedContinuation { continuation in
            self.startWaiters.append((target, continuation))
        }
    }

    func waitForCompletions(_ target: Int) async {
        guard self.completions < target else { return }
        await withCheckedContinuation { continuation in
            self.completionWaiters.append((target, continuation))
        }
    }

    private func resumeSatisfiedWaiters() {
        let readyStarts = self.startWaiters.filter { self.starts >= $0.0 }
        self.startWaiters.removeAll { self.starts >= $0.0 }
        let readyCompletions = self.completionWaiters.filter { self.completions >= $0.0 }
        self.completionWaiters.removeAll { self.completions >= $0.0 }
        for (_, waiter) in readyStarts + readyCompletions {
            waiter.resume()
        }
    }
}

private actor RegressionCountingFlowStorage: TelerouteFlowStorage {
    private var lookups = 0

    var sessionLookupCount: Int { self.lookups }

    func session(for key: TelerouteFlowKey) -> TelerouteFlowSession? {
        self.lookups += 1
        return nil
    }

    func setSession(_ session: TelerouteFlowSession, for key: TelerouteFlowKey) {}

    func removeSession(for key: TelerouteFlowKey) {}
}

private func regressionEvent(updateID: Int) -> TelerouteEvent {
    .init(
        kind: .received,
        routeKind: .command,
        updateId: updateID,
        chatId: nil,
        userId: nil
    )
}
