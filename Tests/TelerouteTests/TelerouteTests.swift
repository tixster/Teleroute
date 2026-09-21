import Foundation
import HTTPTypes
import Testing
@_spi(Testing) @testable import Teleroute

@Suite(.serialized)
struct TelerouteTests {
@Test func routesCommandAndExposesArguments() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.command"))
    let recorder = Recorder<[String]>()

    router.command("start") { context in
        await recorder.record([
            context.command?.name ?? "",
            context.command?.rawValue ?? "",
            context.command?.argumentsText ?? "",
        ])
    }

    await router.process([makeCommandUpdate(text: "/start hello world")])

    let values = await recorder.waitForCount(1)
    #expect(values == [["start", "/start", "hello world"]])
}

@Test func routeGroupsNormalizeCommandsToTelegramFormat() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.group"))
    let recorder = Recorder<String>()

    router.group("admin") { admin in
        admin.command("ban") { context in
            await recorder.record(context.command?.name ?? "")
        }
    }

    await router.process([makeCommandUpdate(text: "/admin_ban 42")])

    let values = await recorder.waitForCount(1)
    #expect(values == ["admin_ban"])
}

@Test func commandBotUsernameRequiresExplicitMention() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.command.bot-username"))
    let recorder = Recorder<String>()

    router.command("start", botUsername: "my_bot") { context in
        await recorder.record(context.command?.rawValue ?? "")
    }

    await router.process([makeCommandUpdate(text: "/start", updateId: 10)])
    try? await Task.sleep(for: .milliseconds(50))
    #expect(await recorder.values.isEmpty)

    await router.process([makeCommandUpdate(text: "/start@other_bot", updateId: 11)])
    try? await Task.sleep(for: .milliseconds(50))
    #expect(await recorder.values.isEmpty)

    await router.process([makeCommandUpdate(text: "/start@My_Bot", updateId: 12)])

    let values = await recorder.waitForCount(1)
    #expect(values == ["/start@My_Bot"])
}

@Test func routesCallbackAndDecodesParameters() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.callback"))
    let recorder = Recorder<[String]>()

    router.callback("orders/{orderId}/items/{itemId}") { context in
        await recorder.record([
            try context.parameters.require("orderId"),
            try context.parameters.require("itemId"),
        ])
    }

    await router.process([
        makeCallbackUpdate(data: "orders/42/items/green%20tea"),
    ])

    let values = await recorder.waitForCount(1)
    #expect(values == [["42", "green tea"]])
}

@Test func buttonUsesRouteScopePrefix() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.button"))
    let admin = router.group("admin")
    let approve = admin.callback(ApproveOrderCallback.self) { _, _ in }

    let button = try router.render(
        approve.button(ApproveOrderCallback(orderID: "A B"), "Open")
    )

    #expect(button.text == "Open")
    #expect(button.callbackData == "admin/orders/A%20B/approve")
}

@Test func keyboardBuildsMultipleTypedButtons() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.keyboard"))
    let approve = router.callback(ApproveOrderCallback.self) { _, _ in }
    let explicitApprove = router.callback(ExplicitApproveOrderCallback.self) { _, _ in }

    let keyboard = try router.keyboard([[
        approve.button(ApproveOrderCallback(orderID: "42"), "Approve"),
        explicitApprove.button(
            ExplicitApproveOrderCallback(orderID: "43"),
            "Explicit approve"
        ),
    ]])

    #expect(keyboard.inlineKeyboard.count == 1)
    #expect(keyboard.inlineKeyboard[0].count == 2)
    #expect(keyboard.inlineKeyboard[0][0].callbackData == "orders/42/approve")
    #expect(keyboard.inlineKeyboard[0][1].callbackData == "orders/43/explicit_approve")
}

@Test func typedCommandDecodesArguments() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.typed-command"))
    let recorder = Recorder<[String]>()

    router.command(BanCommand.self) { command, _ in
        await recorder.record([command.userID, command.reason ?? ""])
    }

    await router.process([makeCommandUpdate(text: "/ban 42 spam")])

    let values = await recorder.waitForCount(1)
    #expect(values == [["42", "spam"]])
}

@Test func commandMatchProvidesRequireHelper() throws {
    let command = TelerouteCommandMatch(
        name: "ban",
        rawValue: "/ban",
        mentionedBotUsername: nil,
        argumentsText: "42 spam",
        arguments: ["42", "spam"]
    )

    #expect(try command.require("userID") == "42")
    #expect(command.get("reason", at: 1) == "spam")
}

@Test func typedCommandUsesExplicitHandler() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.typed-command.self"))

    await ExplicitBanCommand.recorder.reset()
    router.command(ExplicitBanCommand.self) { command, _ in
        await ExplicitBanCommand.recorder.record(command.userID)
    }

    await router.process([makeCommandUpdate(text: "/explicit_ban 77")])

    let values = await ExplicitBanCommand.recorder.waitForCount(1)
    #expect(values == ["77"])
}

@Test func typedCallbackDecodesAndRendersParameters() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.typed-callback"))
    let recorder = Recorder<String>()

    let route = router.callback(ApproveOrderCallback.self) { callback, _ in
        await recorder.record(callback.orderID)
    }

    let data = try router.callbackData(for: ApproveOrderCallback(orderID: "42"))
    await router.process([makeCallbackUpdate(data: data)])

    let button = try router.render(
        route.button(ApproveOrderCallback(orderID: "green tea"), "Approve")
    )
    let values = await recorder.waitForCount(1)

    #expect(values == ["42"])
    #expect(button.callbackData == "orders/green%20tea/approve")
}

@Test func typedCallbackUsesExplicitHandler() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.typed-callback.self"))

    await ExplicitApproveOrderCallback.recorder.reset()
    router.callback(ExplicitApproveOrderCallback.self) { callback, _ in
        await ExplicitApproveOrderCallback.recorder.record(callback.orderID)
    }

    await router.process([makeCallbackUpdate(data: "orders/55/explicit_approve")])

    let values = await ExplicitApproveOrderCallback.recorder.waitForCount(1)
    #expect(values == ["55"])
}

@Test func routeModuleMountsIntoGroup() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.module"))
    let recorder = Recorder<String>()

    router.group("admin") { admin in
        admin.mount(AdminModule(recorder: recorder))
    }

    await router.process([makeCommandUpdate(text: "/admin_ban 42")])

    let values = await recorder.waitForCount(1)
    #expect(values == ["ban:42"])
}

@Test func moduleCanOwnItsPath() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.grouped-module"))
    let recorder = Recorder<String>()

    router.mount(GroupedAdminModule(recorder: recorder))

    await router.process([makeCommandUpdate(text: "/admin_ban 42")])

    let values = await recorder.waitForCount(1)
    #expect(values == ["grouped-ban:42"])
}

@Test func commandGuardsAllowContextSpecificRouting() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.guard.command"))
    let recorder = Recorder<String>()

    router.command("start", guards: [TelerouteChatTypeGuard(.group)]) { _ in
        await recorder.record("group")
    }
    router.command("start", guards: [TelerouteChatTypeGuard(.private)]) { _ in
        await recorder.record("private")
    }

    await router.process([makeCommandUpdate(text: "/start", chatType: .private)])

    let values = await recorder.waitForCount(1)
    #expect(values == ["private"])
}

@Test func callbackGuardsAllowContextSpecificRouting() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.guard.callback"))
    let recorder = Recorder<String>()

    router.callback("orders/{id}/approve", guards: [TelerouteChatTypeGuard(.group)]) { _ in
        await recorder.record("group")
    }
    router.callback("orders/{id}/approve", guards: [TelerouteChatTypeGuard(.private)]) { context in
        await recorder.record(try context.parameters.require("id"))
    }

    await router.process([makeCallbackUpdate(data: "orders/42/approve", chatType: .private)])

    let values = await recorder.waitForCount(1)
    #expect(values == ["42"])
}

@Test func middlewareWrapsHandlerExecution() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.middleware"))
    let recorder = Recorder<[String]>()

    router.command(
        "start",
        middlewares: [RecordingMiddleware(recorder: recorder, label: "mw")]
    ) { _ in
        await recorder.record(["handler"])
    }

    await router.process([makeCommandUpdate(text: "/start")])

    let values = await recorder.waitForCount(3)
    #expect(values == [["mw:before"], ["handler"], ["mw:after"]])
}

@Test func throttleMiddlewareDropsRepeatedUpdatesWithinInterval() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.middleware.throttle"))
    let recorder = Recorder<String>()

    router.command(
        "tap",
        middlewares: [
            TelerouteThrottleMiddleware(
                interval: .milliseconds(200),
                scope: .chatUser
            )
        ]
    ) { context in
        await recorder.record(context.command?.arguments.first ?? "")
    }

    await router.process([makeCommandUpdate(text: "/tap first", updateId: 220)])
    let values = await recorder.waitForCount(1, retries: 100)
    await router.process([makeCommandUpdate(text: "/tap second", updateId: 221)])
    try? await Task.sleep(for: .milliseconds(100))

    #expect(values == ["first"])
    #expect(await recorder.values == ["first"])
}

@Test func throttleMiddlewareConsumesDroppedUpdateBeforeFallbackRoute() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.middleware.throttle.consume"))
    let recorder = Recorder<String>()

    router.command(
        "tap",
        middlewares: [
            TelerouteThrottleMiddleware(
                interval: .milliseconds(200),
                scope: .chatUser
            )
        ]
    ) { context in
        await recorder.record("limited:\(context.command?.arguments.first ?? "")")
    }

    router.command("tap") { context in
        await recorder.record("fallback:\(context.command?.arguments.first ?? "")")
    }

    await router.process([makeCommandUpdate(text: "/tap first", updateId: 222)])
    _ = await recorder.waitForCount(1, retries: 100)
    await router.process([makeCommandUpdate(text: "/tap second", updateId: 223)])
    try? await Task.sleep(for: .milliseconds(100))

    #expect(await recorder.values == ["limited:first"])
}

@Test func debounceMiddlewareHandlesLatestUpdateAfterQuietInterval() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.middleware.debounce"))
    let recorder = Recorder<String>()

    router.command(
        "search",
        middlewares: [
            TelerouteDebounceMiddleware(
                interval: .milliseconds(50),
                scope: .chatUser
            )
        ]
    ) { context in
        await recorder.record(context.command?.arguments.first ?? "")
    }

    await router.process([makeCommandUpdate(text: "/search first", updateId: 230)])
    try? await Task.sleep(for: .milliseconds(20))
    await router.process([makeCommandUpdate(text: "/search second", updateId: 231)])

    let values = await recorder.waitForCount(1, retries: 100)
    try? await Task.sleep(for: .milliseconds(80))
    #expect(values == ["second"])
    #expect(await recorder.values == ["second"])
}

@Test func debounceMiddlewareConsumesSupersededUpdateBeforeFallbackRoute() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.middleware.debounce.consume"))
    let recorder = Recorder<String>()

    router.command(
        "search",
        middlewares: [
            TelerouteDebounceMiddleware(
                interval: .milliseconds(50),
                scope: .chatUser
            )
        ]
    ) { context in
        await recorder.record("debounced:\(context.command?.arguments.first ?? "")")
    }

    router.command("search") { context in
        await recorder.record("fallback:\(context.command?.arguments.first ?? "")")
    }

    await router.process([makeCommandUpdate(text: "/search first", updateId: 232)])
    try? await Task.sleep(for: .milliseconds(20))
    await router.process([makeCommandUpdate(text: "/search second", updateId: 233)])

    _ = await recorder.waitForCount(1, retries: 100)
    try? await Task.sleep(for: .milliseconds(80))

    #expect(await recorder.values == ["debounced:second"])
}

@Test func routerPublishesLifecycleEvents() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.events"))
    let recorder = Recorder<TelerouteEvent>()

    let collectionTask = Task {
        var iterator = router.eventStream().makeAsyncIterator()
        while let event = await iterator.next() {
            await recorder.record(event)
            if await recorder.values.count >= 2 {
                break
            }
        }
    }

    router.command("events") { _ in }

    await router.process([makeCommandUpdate(text: "/events", updateId: 235)])

    let events = await recorder.waitForCount(2, retries: 100)
    collectionTask.cancel()

    #expect(events.contains { $0.kind == .received && $0.updateId == 235 })
    #expect(events.contains { $0.kind == .handled && $0.routeKind == .command && $0.routeName == "events" })
}

@Test func eventEmitterPreservesEmissionOrder() async throws {
    let hub = TelerouteEventHub()
    let eventCount = 50
    let events = hub.sequence(buffering: .unbounded)

    let collectionTask = Task {
        var iterator = events.makeAsyncIterator()
        var updateIds: [Int64] = []
        while updateIds.count < eventCount {
            guard let event = await iterator.next() else { break }
            updateIds.append(event.updateId)
        }
        return updateIds
    }

    for updateId in 0..<eventCount {
        hub.emit(
            .init(
                kind: .received,
                routeKind: .command,
                updateId: Int64(updateId),
                chatId: nil,
                userId: nil
            )
        )
    }

    let updateIds = await collectionTask.value
    hub.finish()

    #expect(updateIds == Array(Int64(0)..<Int64(eventCount)))
}

@Test func eventHubBroadcastsToMultipleConsumers() async throws {
    let hub = TelerouteEventHub()
    // Two independent subscriptions: each gets its own stream/buffer.
    let eventsA = hub.sequence(buffering: .unbounded)
    let eventsB = hub.sequence(buffering: .unbounded)

    let consumerA = Task {
        var iterator = eventsA.makeAsyncIterator()
        var updateIds: [Int64] = []
        while updateIds.count < 3 {
            guard let event = await iterator.next() else { break }
            updateIds.append(event.updateId)
        }
        return updateIds
    }
    let consumerB = Task {
        var iterator = eventsB.makeAsyncIterator()
        var updateIds: [Int64] = []
        while updateIds.count < 3 {
            guard let event = await iterator.next() else { break }
            updateIds.append(event.updateId)
        }
        return updateIds
    }

    try? await Task.sleep(for: .milliseconds(20))
    for updateId in 1...3 {
        hub.emit(.init(kind: .handled, routeKind: .command, updateId: Int64(updateId), chatId: nil, userId: nil))
    }

    let idsA = await consumerA.value
    let idsB = await consumerB.value
    hub.finish()

    #expect(idsA == [1, 2, 3])
    #expect(idsB == [1, 2, 3])
}

@Test func onErrorReceivesHandlerErrors() async throws {
    struct BoomError: Error {}
    let bot = try await makeBot()
    let recorder = Recorder<String>()

    let router = TelerouteRuntime(
        bot: bot,
        logger: .init(label: "router.error"),
        configuration: .init(onError: { error, _ in
            await recorder.record(String(describing: error))
        })
    )

    router.command("boom") { (_: TelerouteContext) -> Void in
        throw BoomError()
    }

    await router.process([makeCommandUpdate(text: "/boom", updateId: 600)])

    let captured = await recorder.waitForCount(1)
    #expect(captured == ["BoomError()"])
}

@Test func failedEventCarriesTypedError() async throws {
    struct BoomError: Error & Equatable {}
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.failed-event"))
    let recorder = Recorder<TelerouteEvent>()

    let eventTask = Task {
        for await event in router.eventStream() {
            await recorder.record(event)
            if event.kind == .failed { break }
        }
    }

    router.command("boom") { (_: TelerouteContext) -> Void in
        throw BoomError()
    }

    await router.process([makeCommandUpdate(text: "/boom", updateId: 601)])
    _ = await recorder.waitForCount(2, retries: 100)

    eventTask.cancel()
    try? await Task.sleep(for: .milliseconds(30))

    let failed = await recorder.values.last { $0.kind == .failed }
    #expect(failed != nil)
    #expect(failed?.error is BoomError)
}

@Test func flowRoutesMessagesAndCallbacksByActiveStep() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.flow"))
    let recorder = Recorder<String>()

    router.flow(SignupFlow(recorder: recorder))

    await router.process([makeCommandUpdate(text: "/signup")])
    _ = await recorder.waitForCount(1)
    await router.process([makeMessageUpdate(text: "Alice")])
    _ = await recorder.waitForCount(2)
    await router.process([makeCallbackUpdate(data: "confirm/approve")])
    await router.process([makeMessageUpdate(text: "ignored")])

    let values = await recorder.waitForCount(3)
    #expect(values == ["start", "name:Alice", "confirm:Alice:approve"])
}

@Test func flowCommandHandlesActiveStepBeforeFallbackCancellation() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.flow.command"))
    let recorder = Recorder<String>()

    router.flow(SignupFlow(recorder: recorder))

    await router.process([makeCommandUpdate(text: "/signup", updateId: 240)])
    _ = await recorder.waitForCount(1)
    await router.process([makeMessageUpdate(text: "Alice", updateId: 241)])
    _ = await recorder.waitForCount(2)
    await router.process([makeCommandUpdate(text: "/cancel", updateId: 242)])
    await router.process([makeMessageUpdate(text: "ignored", updateId: 243)])

    let values = await recorder.waitForCount(3)
    #expect(values == ["start", "name:Alice", "cancel:Alice"])
}

@Test func flowMessagesForSameSessionSeeLatestSessionSequentially() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.flow.serial"))
    let recorder = Recorder<String>()

    router.flow(SignupFlow(recorder: recorder))

    await router.process([makeCommandUpdate(text: "/signup", updateId: 250)])
    _ = await recorder.waitForCount(1)
    await router.process([
        makeMessageUpdate(text: "Alice", updateId: 251),
        makeMessageUpdate(text: "Bob", updateId: 252),
    ])

    _ = await recorder.waitForCount(2, retries: 200)
    try? await Task.sleep(for: .milliseconds(100))

    let values = await recorder.values
    #expect(values.count == 2)
    #expect(values.first == "start")
    #expect(["name:Alice", "name:Bob"].contains(values.last ?? ""))
}

@Test func flowRoutesCallbackUsingCallbackSenderWhenMessageWasSentByBot() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.flow.callback-user"))
    let recorder = Recorder<String>()

    router.flow(SignupFlow(recorder: recorder))

    await router.process([makeCommandUpdate(text: "/signup", userId: 42, chatId: 42)])
    _ = await recorder.waitForCount(1)
    await router.process([makeMessageUpdate(text: "Alice", userId: 42, chatId: 42)])
    _ = await recorder.waitForCount(2)
    await router.process([
        makeCallbackUpdate(
            data: "confirm/approve",
            messageUserId: 9_999,
            messageIsBot: true,
            callbackUserId: 42,
            chatId: 42
        )
    ])

    let values = await recorder.waitForCount(3)
    #expect(values == ["start", "name:Alice", "confirm:Alice:approve"])
}

@Test func commandCancelsActiveFlowAndFallsBackToRegularRouting() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.flow.cancel"))
    let recorder = Recorder<String>()

    router.flow(SignupFlow(recorder: recorder))
    router.command("help") { _ in
        await recorder.record("help")
    }

    await router.process([makeCommandUpdate(text: "/signup")])
    _ = await recorder.waitForCount(1)
    await router.process([makeCommandUpdate(text: "/help")])
    _ = await recorder.waitForCount(2)
    await router.process([makeMessageUpdate(text: "Alice")])

    let values = await recorder.waitForCount(2)
    #expect(values == ["start", "help"])
}

@Test func canInjectCustomFlowStorage() async throws {
    let bot = try await makeBot()
    let flowStorage = TestFlowStorage()
    let router = TelerouteRuntime(
        bot: bot,
        logger: .init(label: "router.flow.storage"),
        configuration: .init(flowStorage: flowStorage)
    )
    let key = TelerouteFlowKey(chatId: 1, userId: 1)

    router.flow(SignupFlow(recorder: Recorder<String>()))

    await router.process([makeCommandUpdate(text: "/signup")])

    let session = await flowStorage.waitForSession(for: key)
    #expect(session?.id == SignupFlow.id)
    #expect(session?.step == SignupFlow.Step.name.rawValue)
}

@Test func replayProtectionDeduplicatesRepeatedCommands() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(
        bot: bot,
        logger: .init(label: "router.replay.command"),
        configuration: .init(replayProtectionTTL: .seconds(5))
    )
    let recorder = Recorder<String>()

    router.command("start") { _ in
        await recorder.record("start")
    }

    await router.process([makeCommandUpdate(text: "/start", updateId: 100)])
    await router.process([makeCommandUpdate(text: "/start", updateId: 101)])

    let values = await recorder.waitForCount(1)
    #expect(values == ["start"])
}

@Test func replayProtectionDeduplicatesRepeatedCallbacks() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(
        bot: bot,
        logger: .init(label: "router.replay.callback"),
        configuration: .init(replayProtectionTTL: .seconds(5))
    )
    let recorder = Recorder<String>()

    router.callback("orders/{id}/approve") { context in
        await recorder.record(try context.parameters.require("id"))
    }

    await router.process([makeCallbackUpdate(data: "orders/42/approve", updateId: 200)])
    await router.process([makeCallbackUpdate(data: "orders/42/approve", updateId: 201)])

    let values = await recorder.waitForCount(1)
    #expect(values == ["42"])
}

@Test func replayProtectionCleanupRemovesExpiredKeys() async throws {
    let storage = TelerouteInMemoryReplayProtectionStorage()

    #expect(await storage.claim(key: "command|1|1|start", ttl: .milliseconds(20)))
    #expect(await storage.storedKeyCount == 1)
    try? await Task.sleep(for: .milliseconds(40))
    await storage.removeExpired()

    #expect(await storage.storedKeyCount == 0)
}

@Test func queuedCommandsRunSequentiallyForSameChatUser() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.queue.command"))
    let recorder = Recorder<String>()
    let probe = ConcurrencyProbe()

    router.command("sync", queue: .perChatAndUser) { (context: TelerouteContext) -> Void in
        let value = context.command?.arguments.first ?? "unknown"
        await recorder.record("start:\(value)")
        await probe.enter()
        try? await Task.sleep(for: .milliseconds(50))
        await probe.leave()
        await recorder.record("end:\(value)")
    }

    await router.process([
        makeCommandUpdate(text: "/sync 1", updateId: 300),
        makeCommandUpdate(text: "/sync 2", updateId: 301),
    ])

    let values = await recorder.waitForCount(4, retries: 200)
    let expectedOrders = [
        ["start:1", "end:1", "start:2", "end:2"],
        ["start:2", "end:2", "start:1", "end:1"],
    ]

    #expect(await probe.maxConcurrent == 1)
    #expect(expectedOrders.contains(values))
    try? await Task.sleep(for: .milliseconds(20))
}

@Test func typedCommandUsesQueueDeclaredOnSpec() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.queue.typed-command"))
    let recorder = Recorder<String>()
    let probe = ConcurrencyProbe()

    router.command(QueuedCommand.self) { command, _ in
        await recorder.record("start:\(command.value)")
        await probe.enter()
        try? await Task.sleep(for: .milliseconds(50))
        await probe.leave()
        await recorder.record("end:\(command.value)")
    }

    await router.process([
        makeCommandUpdate(text: "/queued 1", updateId: 302),
        makeCommandUpdate(text: "/queued 2", updateId: 303),
    ])

    let values = await recorder.waitForCount(4, retries: 200)
    let expectedOrders = [
        ["start:1", "end:1", "start:2", "end:2"],
        ["start:2", "end:2", "start:1", "end:1"],
    ]

    #expect(await probe.maxConcurrent == 1)
    #expect(expectedOrders.contains(values))
    try? await Task.sleep(for: .milliseconds(20))
}

@Test func publishedCommandsGroupByVisibility() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.commands.visibility"))

    router.command(
        "start",
        description: "Start the bot"
    ) { _ in }
    router.command(
        "ban",
        description: "Ban a user",
        visibility: [.allGroupChats, .allChatAdministrators]
    ) { _ in }
    router.command(
        "start",
        description: "Start the bot",
        guards: [TelerouteChatTypeGuard(.private)]
    ) { _ in }

    let commandSets = try router.publishedCommandSets()

    #expect(commandSets.count == 3)
    #expect(scopeKey(commandSets[0].visibility) == "default")
    #expect(commandSets[0].commands.map(\.command) == ["start"])
    #expect(scopeKey(commandSets[1].visibility) == "allGroupChats")
    #expect(commandSets[1].commands.map(\.command) == ["ban"])
    #expect(scopeKey(commandSets[2].visibility) == "allChatAdministrators")
    #expect(commandSets[2].commands.map(\.command) == ["ban"])
}

@Test func duplicateRouteSignaturesAreReportedForUnguardedRoutes() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.duplicates"))

    router.command("start") { _ in }
    router.command("start") { _ in }
    router.callback("orders/{id}") { _ in }
    router.callback("orders/{id}") { _ in }

    let duplicates = router.duplicateRouteSignatures

    #expect(duplicates.map(\.kind) == [.command, .callback])
    #expect(duplicates.map(\.name) == ["start", "orders/{id}"])
}

@Test func guardedDuplicateRoutesAreNotReportedAsDuplicates() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.guarded-duplicates"))

    router.command("start", guards: [TelerouteChatTypeGuard(.private)]) { _ in }
    router.command("start", guards: [TelerouteChatTypeGuard(.group)]) { _ in }

    #expect(router.duplicateRouteSignatures.isEmpty)
}

@Test func typedCommandPublishesUsingSpecVisibility() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.commands.typed-visibility"))

    router.command(VisibleCommand.self) { _, _ in }

    let commandSets = try router.publishedCommandSets()

    #expect(commandSets.count == 1)
    #expect(commandSets[0].commands.map(\.command) == ["visible"])
    #expect(commandSets[0].commands.map(\.description) == ["Visible command"])
}

@Test func conflictingPublishedCommandDescriptionsThrow() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.commands.duplicate"))

    router.command("start", description: "Start") { _ in }
    router.command("start", description: "Boot") { _ in }

    #expect(throws: TelerouteError.self) {
        _ = try router.publishedCommandSets()
    }
}

@Test func routerCanPublishExplicitCommands() async throws {
    let recorder = PublishedCommandsRecorder()
    let bot = try await makeBot(transport: RecordingCommandsTransport(recorder: recorder))
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.commands.publish"))

    try await router.publishCommands(
        [("profile", "Open profile")],
        visibility: .allPrivateChats
    )

    let params = try await recorder.waitForCount(1).first.unwrap()
    #expect(params.commands.map(\.command) == ["profile"])
    #expect(params.commands.map(\.description) == ["Open profile"])
    #expect(scopeKey(params.scope) == "allPrivateChats")
}

@Test func contextCanPublishExplicitCommands() async throws {
    let recorder = PublishedCommandsRecorder()
    let bot = try await makeBot(transport: RecordingCommandsTransport(recorder: recorder))
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.commands.context-publish"))

    router.command("start") { context in
        try await context.publishCommands(
            [("profile", "Open profile")],
            visibility: .chat(.id(1))
        )
    }

    await router.process([makeCommandUpdate(text: "/start", updateId: 400)])

    let params = try await recorder.waitForCount(1).first.unwrap()
    #expect(params.commands.map(\.command) == ["profile"])
    #expect(scopeKey(params.scope) == "chat:1")
}

@Test func routerCanPublishTypedCommands() async throws {
    let recorder = PublishedCommandsRecorder()
    let bot = try await makeBot(transport: RecordingCommandsTransport(recorder: recorder))
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.commands.publish.typed"))

    try await router.publishCommands([VisibleCommand.self])

    let params = try await recorder.waitForCount(1).first.unwrap()
    #expect(params.commands.map(\.command) == ["visible"])
    #expect(params.commands.map(\.description) == ["Visible command"])
    #expect(scopeKey(params.scope) == "allPrivateChats")
}

@Test func contextCanPublishTypedCommands() async throws {
    let recorder = PublishedCommandsRecorder()
    let bot = try await makeBot(transport: RecordingCommandsTransport(recorder: recorder))
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.commands.context-publish.typed"))

    router.command("start") { context in
        try await context.publishCommands([VisibleCommand.self], visibility: .chat(.id(1)))
    }

    await router.process([makeCommandUpdate(text: "/start", updateId: 401)])

    let params = try await recorder.waitForCount(1).first.unwrap()
    #expect(params.commands.map(\.command) == ["visible"])
    #expect(params.commands.map(\.description) == ["Visible command"])
    #expect(scopeKey(params.scope) == "chat:1")
}

@Test func replayProtectionReHandlesAfterTTLExpires() async throws {
    let bot = try await makeBot()
    let storage = TelerouteInMemoryFlowStorage()
    let replayStorage = TelerouteInMemoryReplayProtectionStorage()
    let router = TelerouteRuntime(
        bot: bot,
        logger: .init(label: "router.replay.ttl"),
        configuration: .init(
            flowStorage: storage,
            replayProtectionStorage: replayStorage,
            replayProtectionTTL: .milliseconds(40)
        )
    )
    let recorder = Recorder<String>()

    router.command("start") { _ in
        await recorder.record("start")
    }

    await router.process([makeCommandUpdate(text: "/start", updateId: 500)])
    _ = await recorder.waitForCount(1)

    // Same update within the TTL window is suppressed.
    await router.process([makeCommandUpdate(text: "/start", updateId: 501)])
    try? await Task.sleep(for: .milliseconds(5))
    #expect(await recorder.values.count == 1)

    // After the TTL expires the command is handled again.
    try? await Task.sleep(for: .milliseconds(50))
    await router.process([makeCommandUpdate(text: "/start", updateId: 502)])
    _ = await recorder.waitForCount(2)

    #expect(await recorder.values == ["start", "start"])
}

@Test func queuedCommandsRunSequentiallyForGlobalScope() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.queue.global"))
    let recorder = Recorder<String>()
    let probe = ConcurrencyProbe()

    router.command("sync", queue: .global) { (context: TelerouteContext) -> Void in
        let value = context.command?.arguments.first ?? "unknown"
        await recorder.record("start:\(value)")
        await probe.enter()
        try? await Task.sleep(for: .milliseconds(50))
        await probe.leave()
        await recorder.record("end:\(value)")
    }

    // Different chats and users share the global queue, so they must serialize.
    await router.process([
        makeCommandUpdate(text: "/sync 1", userId: 10, chatId: 10, updateId: 510),
        makeCommandUpdate(text: "/sync 2", userId: 20, chatId: 20, updateId: 511),
    ])

    let values = await recorder.waitForCount(4, retries: 200)
    let expectedOrders = [
        ["start:1", "end:1", "start:2", "end:2"],
        ["start:2", "end:2", "start:1", "end:1"],
    ]
    #expect(await probe.maxConcurrent == 1)
    #expect(expectedOrders.contains(values))
    try? await Task.sleep(for: .milliseconds(20))
}

@Test func queuedCommandsSerializePerChatButRunInParallelAcrossChats() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.queue.chat"))
    let probe = ConcurrencyProbe()

    router.command("sync", queue: .perChat) { (_: TelerouteContext) -> Void in
        await probe.enter()
        try? await Task.sleep(for: .milliseconds(50))
        await probe.leave()
    }

    // Same chat, different users: serialized.
    // Different chat: allowed to run in parallel with the first.
    await router.process([
        makeCommandUpdate(text: "/sync", userId: 1, chatId: 1, updateId: 520),
        makeCommandUpdate(text: "/sync", userId: 2, chatId: 1, updateId: 521),
        makeCommandUpdate(text: "/sync", userId: 3, chatId: 2, updateId: 522),
    ])

    try? await Task.sleep(for: .milliseconds(120))
    // Two independent chats → up to two concurrent handlers.
    #expect(await probe.maxConcurrent == 2)
}

@Test func flowValuesMergePreservesExistingKeysAndOverwritesConflicts() {
    let initial = TelerouteFlowValues(["name": "Alice", "age": "30"])
    let merged = initial.merging(["age": "31", "city": "Berlin"])
    #expect(merged.get("name") == "Alice")
    #expect(merged.get("age") == "31")
    #expect(merged.get("city") == "Berlin")
}

@Test func contextSendThrowsWhenChatCannotBeResolved() async throws {
    let bot = try await makeBot()
    // An update without a message or callback query yields no resolvable chat.
    let update = Update(updateId: 530)
    let context = TelerouteContext(bot: bot, update: update)

    await #expect(throws: TelerouteError.self) {
        try await context.send("hello")
    }
}

@Test func contextEditThrowsWhenMessageIsMissing() async throws {
    let bot = try await makeBot()
    let update = Update(updateId: 531)
    let context = TelerouteContext(bot: bot, update: update)

    await #expect(throws: TelerouteError.self) {
        try await context.edit("edited")
    }
}

@Test func contextAnswerCallbackQueryThrowsWhenCallbackIsMissing() async throws {
    let bot = try await makeBot()
    let update = Update(updateId: 532)
    let context = TelerouteContext(bot: bot, update: update)

    await #expect(throws: TelerouteError.self) {
        try await context.answerCallbackQuery("ack")
    }
}

@Test func debounceCancelsSilentlyWithoutFailedEvent() async throws {
    let bot = try await makeBot()
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.debounce.cancel"))
    let recorder = Recorder<TelerouteEvent.Kind>()

    router.command("save", middlewares: [TelerouteDebounceMiddleware(interval: .seconds(10))]) { _ in
        await recorder.record(.handled)
    }

    let events = router.eventStream()
    let eventTask = Task {
        for await event in events {
            await recorder.record(event.kind)
        }
    }

    await router.process([makeCommandUpdate(text: "/save", updateId: 540)])
    // Let the debounce arm, then tear down processing tasks to cancel the sleep.
    try? await Task.sleep(for: .milliseconds(20))

    eventTask.cancel()
    try? await Task.sleep(for: .milliseconds(50))

    let kinds = await recorder.values
    #expect(kinds.contains(.failed) == false)
}

@Test func flowPreservesSessionWhenPolicyIsManual() async throws {
    let bot = try await makeBot()
    let storage = TelerouteInMemoryFlowStorage()
    let router = TelerouteRuntime(
        bot: bot,
        logger: .init(label: "router.flow.manual"),
        configuration: .init(
            flowStorage: storage,
            flowCancellationPolicy: .manual
        )
    )
    let recorder = Recorder<String>()

    router.flow(SignupFlow(recorder: recorder))

    await router.process([makeCommandUpdate(text: "/signup", updateId: 550)])
    _ = await recorder.waitForCount(1)
    await router.process([makeMessageUpdate(text: "Alice", updateId: 551)])
    _ = await recorder.waitForCount(2)

    // An unrelated command must NOT cancel the session under `.manual`.
    await router.process([makeCommandUpdate(text: "/help", updateId: 552)])
    try? await Task.sleep(for: .milliseconds(30))
    let flowKey = TelerouteFlowKey(chatId: 1, userId: 1)
    let sessionAfterHelp = await storage.session(for: flowKey)
    #expect(sessionAfterHelp != nil)

    // Subsequent messages are still captured by the flow.
    await router.process([makeMessageUpdate(text: "Bob", updateId: 553)])
    _ = await recorder.waitForCount(3, retries: 100)

    let values = await recorder.values
    #expect(values.first == "start")
    #expect(["name:Alice", "name:Bob"].contains(values.last ?? ""))
}

@Test func queueResumesPendingCallerWithCancellationOnTeardown() async throws {
    let queue = TelerouteCommandQueue(workerIdleTimeout: .seconds(30))
    // Submit one long-running operation so the worker is busy, then enqueue a
    // second that will be parked. Cancelling the second caller's task must
    // resume its continuation with CancellationError instead of hanging.
    let gate = TestGate()
    let first = Task {
        try await queue.enqueue(key: "k") {
            await gate.wait()
            return 1
        }
    }
    try? await Task.sleep(for: .milliseconds(20))

    let second = Task {
        try await queue.enqueue(key: "k") { 2 }
    }
    try? await Task.sleep(for: .milliseconds(20))
    second.cancel()

    await #expect(throws: CancellationError.self) {
        _ = try await second.value
    }

    await gate.release()
    _ = try await first.value
}

@Test func duplicatePublishedCommandIsPublishedOnceWhenDescriptionsMatch() async throws {
    let recorder = PublishedCommandsRecorder()
    let bot = try await makeBot(transport: RecordingCommandsTransport(recorder: recorder))
    let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.commands.dedup"))

    // Same command registered twice with identical description: published once.
    router.command("start", description: "Begin", visibility: [.default]) { _ in }
    router.command("start", description: "Begin", visibility: [.default]) { _ in }

    let sets = try router.publishedCommandSets()
    #expect(sets.count == 1)
    #expect(sets.first?.commands.count == 1)
    #expect(sets.first?.commands.first?.command == "start")
}
}


private actor Recorder<Value: Sendable> {
    private var storage: [Value] = []

    func record(_ value: Value) {
        self.storage.append(value)
    }

    func reset() {
        self.storage.removeAll()
    }

    var values: [Value] {
        self.storage
    }

    func waitForCount(_ count: Int, retries: Int = 50) async -> [Value] {
        for _ in 0..<retries {
            if self.storage.count >= count {
                return self.storage
            }
            try? await Task.sleep(for: .milliseconds(10))
        }
        return self.storage
    }
}

private actor ConcurrencyProbe {
    private var running = 0
    private var maxRunning = 0

    func enter() {
        self.running += 1
        self.maxRunning = max(self.maxRunning, self.running)
    }

    func leave() {
        self.running -= 1
    }

    var maxConcurrent: Int {
        self.maxRunning
    }
}

private actor TestGate {
    private var released = false

    func wait() async {
        while self.released == false {
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    func release() {
        self.released = true
    }
}

private actor PublishedCommandsRecorder {
    private var calls: [DecodedSetMyCommandsParams] = []

    func record(_ params: DecodedSetMyCommandsParams) {
        self.calls.append(params)
    }

    func waitForCount(_ count: Int, retries: Int = 50) async -> [DecodedSetMyCommandsParams] {
        for _ in 0..<retries {
            if self.calls.count >= count {
                return self.calls
            }
            try? await Task.sleep(for: .milliseconds(10))
        }
        return self.calls
    }
}

private enum TestError: Error {
    case unexpectedNetworkCall
    case unexpectedClientCall
}

private struct BanCommand: TelerouteCommand {
    static let path = "ban"

    let userID: String
    let reason: String?

    init(command: TelerouteCommandMatch) throws {
        self.userID = try command.require("userID")
        self.reason = command.get("reason", at: 1)
    }
}

private struct ExplicitBanCommand: TelerouteCommand {
    static let path = "explicit_ban"
    static let recorder = Recorder<String>()

    let userID: String

    init(command: TelerouteCommandMatch) throws {
        self.userID = try command.require("userID")
    }

}

private struct QueuedCommand: TelerouteCommand {
    static let path = "queued"
    static let queue: TelerouteQueueScope? = .perChatAndUser

    let value: String

    init(command: TelerouteCommandMatch) throws {
        self.value = try command.require("value")
    }
}

private struct VisibleCommand: TelerouteCommand {
    static let path = "visible"
    static let commandDescription: String? = "Visible command"
    static let visibility: [TelerouteCommandVisibility] = [.allPrivateChats]

    init(command: TelerouteCommandMatch) throws {}
}

private struct ApproveOrderCallback: TelerouteCallback {
    static let path = "orders/{orderID}/approve"

    let orderID: String

    init(orderID: String) {
        self.orderID = orderID
    }

    init(parameters: TelerouteParameters) throws {
        self.orderID = try parameters.require("orderID")
    }

    var parameters: [String: String] {
        ["orderID": self.orderID]
    }
}

private struct ExplicitApproveOrderCallback: TelerouteCallback {
    static let path = "orders/{orderID}/explicit_approve"
    static let recorder = Recorder<String>()

    let orderID: String

    init(orderID: String) {
        self.orderID = orderID
    }

    init(parameters: TelerouteParameters) throws {
        self.orderID = try parameters.require("orderID")
    }

    var parameters: [String: String] {
        ["orderID": self.orderID]
    }

}

private struct AdminModule: TelerouteModule {
    let recorder: Recorder<String>

    func register(in routes: TelerouteRoutes) {
        routes.command("ban") { context in
            await self.recorder.record("ban:\(context.command?.arguments.first ?? "")")
        }
    }
}

private struct GroupedAdminModule: TelerouteModule {
    let recorder: Recorder<String>

    func register(in routes: TelerouteRoutes) {
        routes.group("admin").command("ban") { context in
            await self.recorder.record("grouped-ban:\(context.command?.arguments.first ?? "")")
        }
    }
}

private struct RecordingMiddleware: TelerouteMiddleware {
    let recorder: Recorder<[String]>
    let label: String

    func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> TelerouteResponse
    ) async throws -> TelerouteResponse {
        await self.recorder.record(["\(self.label):before"])
        let response = try await next(context)
        await self.recorder.record(["\(self.label):after"])
        return response
    }
}

private actor TestFlowStorage: TelerouteFlowStorage {
    private var sessions: [TelerouteFlowKey: TelerouteFlowSession] = [:]

    func session(for key: TelerouteFlowKey) -> TelerouteFlowSession? {
        self.sessions[key]
    }

    func setSession(_ session: TelerouteFlowSession, for key: TelerouteFlowKey) {
        self.sessions[key] = session
    }

    func removeSession(for key: TelerouteFlowKey) {
        self.sessions.removeValue(forKey: key)
    }

    func waitForSession(
        for key: TelerouteFlowKey,
        retries: Int = 50
    ) async -> TelerouteFlowSession? {
        for _ in 0..<retries {
            if let session = self.sessions[key] {
                return session
            }
            try? await Task.sleep(for: .milliseconds(10))
        }
        return self.sessions[key]
    }
}

private struct SignupFlow: TelerouteFlow {
    enum Step: String, Sendable {
        case name
        case confirm
    }

    let recorder: Recorder<String>

    func boot(flow: TelerouteFlowGroup<SignupFlow>) {
        flow.start("signup", at: .name) { _ in
            await self.recorder.record("start")
        }

        flow.message(at: .name) { context in
            let name = context.message?.text ?? ""
            await self.recorder.record("name:\(name)")
            try await context.transition(to: .confirm, merging: ["name": name])
        }

        flow.command("cancel", at: .confirm) { context in
            let name = try context.values.require("name")
            await self.recorder.record("cancel:\(name)")
            try await context.finish()
        }

        flow.callback("confirm/{decision}", at: .confirm) { context in
            let name = try context.values.require("name")
            let decision = try context.parameters.require("decision")
            await self.recorder.record("confirm:\(name):\(decision)")
            try await context.finish()
        }
    }
}

private struct TestTransport: TelegramTransport {
    func send(
        _ request: HTTPRequest,
        body: Data?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, Data) {
        throw TestError.unexpectedNetworkCall
    }
}

private struct RecordingCommandsTransport: TelegramTransport {
    let recorder: PublishedCommandsRecorder

    func send(
        _ request: HTTPRequest,
        body: Data?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, Data) {
        guard operationID == "setMyCommands", let body else {
            throw TestError.unexpectedClientCall
        }

        let decoded = try JSONDecoder().decode(DecodedSetMyCommandsParams.self, from: body)
        await self.recorder.record(decoded)

        var response = HTTPResponse(status: .ok)
        response.headerFields[.contentType] = "application/json"
        return (response, Data(#"{"ok":true,"result":true}"#.utf8))
    }
}

private struct DecodedSetMyCommandsParams: Decodable {
    let commands: [BotCommand]
    let scope: RawScope?
    let languageCode: String?

    private enum CodingKeys: String, CodingKey {
        case commands
        case scope
        case languageCode = "language_code"
    }

    struct RawScope: Decodable {
        let type: String
        let chatId: ChatId?
        let userId: Int64?

        private enum CodingKeys: String, CodingKey {
            case type
            case chatId = "chat_id"
            case userId = "user_id"
        }
    }
}

private func makeBot() async throws -> TelegramBotClient {
    try await makeBot(transport: TestTransport())
}

private func makeBot(transport: some TelegramTransport) async throws -> TelegramBotClient {
    try TelegramBotClient(token: "123456:test-token", transport: transport)
}

private func makeCommandUpdate(
    text: String,
    chatType: ChatType = .private,
    userId: Int64 = 1,
    chatId: Int64 = 1,
    updateId: Int64 = 1
) -> Update {
    let commandToken = String(text.split(maxSplits: 1, whereSeparator: \.isWhitespace).first ?? "")
    let entity = MessageEntity.botCommand(
        offset: 0,
        length: Int64(commandToken.utf16.count)
    )
    let message = Message(
        messageId: 1,
        from: makeUser(id: userId),
        date: 1,
        chat: makeChat(id: chatId, type: chatType),
        text: text,
        entities: [entity]
    )
    return Update(updateId: Int64(updateId), message: message)
}

private func makeMessageUpdate(
    text: String,
    chatType: ChatType = .private,
    userId: Int64 = 1,
    chatId: Int64 = 1,
    updateId: Int64 = 3
) -> Update {
    let message = Message(
        messageId: 3,
        from: makeUser(id: userId),
        date: 1,
        chat: makeChat(id: chatId, type: chatType),
        text: text
    )
    return Update(updateId: Int64(updateId), message: message)
}

private func makeCallbackUpdate(
    data: String,
    chatType: ChatType = .private,
    messageUserId: Int64 = 1,
    messageIsBot: Bool = false,
    callbackUserId: Int64 = 1,
    chatId: Int64 = 1,
    updateId: Int64 = 2
) -> Update {
    let message = Message(
        messageId: 1,
        from: makeUser(id: messageUserId, isBot: messageIsBot),
        date: 1,
        chat: makeChat(id: chatId, type: chatType),
        text: "callback host"
    )
    let callbackQuery = CallbackQuery(
        id: "callback-id",
        from: makeUser(id: callbackUserId),
        message: .Message(message),
        chatInstance: "chat-instance",
        data: data
    )
    return Update(updateId: Int64(updateId), callbackQuery: callbackQuery)
}

private func makeUser(id: Int64 = 1, isBot: Bool = false) -> User {
    User(id: id, isBot: isBot, firstName: "Test", username: "tester")
}

private func makeChat(id: Int64 = 1, type: ChatType = .private) -> Chat {
    Chat(id: id, type: type, firstName: "Test")
}

private func scopeKey(_ scope: DecodedSetMyCommandsParams.RawScope?) -> String {
    guard let scope else { return "nil" }

    switch scope.type {
    case "default":
        return "default"
    case "all_private_chats":
        return "allPrivateChats"
    case "all_group_chats":
        return "allGroupChats"
    case "all_chat_administrators":
        return "allChatAdministrators"
    case "chat":
        switch scope.chatId {
        case let .case1(id):
            return "chat:\(id)"
        case let .case2(username):
            return "chat:\(username)"
        case nil:
            return "chat:undefined"
        }
    case "chat_administrators":
        switch scope.chatId {
        case let .case1(id):
            return "chatAdministrators:\(id)"
        case let .case2(username):
            return "chatAdministrators:\(username)"
        case nil:
            return "chatAdministrators:undefined"
        }
    case "chat_member":
        let chat: String
        switch scope.chatId {
        case let .case1(id):
            chat = "\(id)"
        case let .case2(username):
            chat = username
        case nil:
            chat = "undefined"
        }
        return "chatMember:\(chat):\(scope.userId ?? 0)"
    default:
        return scope.type
    }
}

private func scopeKey(_ visibility: TelerouteCommandVisibility) -> String {
    switch visibility.scope {
    case .default:
        return "default"
    case .allPrivateChats:
        return "allPrivateChats"
    case .allGroupChats:
        return "allGroupChats"
    case .allChatAdministrators:
        return "allChatAdministrators"
    case let .chat(chat):
        return "chat:\(chat.storageKey())"
    case let .chatAdministrators(chat):
        return "chatAdministrators:\(chat.storageKey())"
    case let .chatMember(chat, userID):
        return "chatMember:\(chat.storageKey()):\(userID)"
    }
}

private extension Optional {
    func unwrap() throws -> Wrapped {
        guard let self else {
            throw TestError.unexpectedClientCall
        }
        return self
    }
}
