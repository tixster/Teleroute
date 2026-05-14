import Testing
@testable import Teleroute

@Suite(.serialized)
struct TelerouteTests {
@Test func routesCommandAndExposesArguments() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.command"))
    let recorder = Recorder<[String]>()

    router.command("start") { _, context in
        await recorder.record([
            context.command?.name ?? "",
            context.command?.rawValue ?? "",
            context.command?.argumentsText ?? "",
        ])
    }

    await router.handle()
    await router.process([makeCommandUpdate(text: "/start hello world")])

    let values = await recorder.waitForCount(1)
    #expect(values == [["start", "/start", "hello world"]])
}

@Test func routeGroupsNormalizeCommandsToTelegramFormat() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.group"))
    let recorder = Recorder<String>()

    router.group("admin") { admin in
        admin.command("ban") { _, context in
            await recorder.record(context.command?.name ?? "")
        }
    }

    await router.handle()
    await router.process([makeCommandUpdate(text: "/admin_ban 42")])

    let values = await recorder.waitForCount(1)
    #expect(values == ["admin_ban"])
}

@Test func commandBotUsernameRequiresExplicitMention() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.command.bot-username"))
    let recorder = Recorder<String>()

    router.command("start", botUsername: "my_bot") { _, context in
        await recorder.record(context.command?.rawValue ?? "")
    }

    await router.handle()
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
    let router = Teleroute(bot: bot, logger: .init(label: "router.callback"))
    let recorder = Recorder<[String]>()

    router.callback("orders/{orderId}/items/{itemId}") { _, context in
        await recorder.record([
            try context.parameters.require("orderId"),
            try context.parameters.require("itemId"),
        ])
    }

    let callbackData = try router.callbackData(
        "orders/{orderId}/items/{itemId}",
        parameters: [
            "orderId": "42",
            "itemId": "green tea",
        ]
    )

    await router.handle()
    await router.process([makeCallbackUpdate(data: callbackData)])

    let values = await recorder.waitForCount(1)
    #expect(values == [["42", "green tea"]])
}

@Test func callbackButtonUsesGroupPrefix() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.button"))

    let button = try router
        .group("admin")
        .callbackButton("Open", path: "orders/{id}", parameters: ["id": "A B"])

    #expect(button.text == "Open")
    #expect(button.callbackData == "admin/orders/A%20B")
}

@Test func callbackKeyboardBuildsMultipleButtons() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.keyboard"))

    let row = try router.callbackButtons([
        ("Approve", ApproveOrderCallback(orderID: "42")),
        ("Self approve", SelfHandlingApproveOrderCallback(orderID: "43")),
    ])

    let keyboard = router.callbackKeyboard([row])

    #expect(keyboard.inlineKeyboard.count == 1)
    #expect(keyboard.inlineKeyboard[0].count == 2)
    #expect(keyboard.inlineKeyboard[0][0].callbackData == "orders/42/approve")
    #expect(keyboard.inlineKeyboard[0][1].callbackData == "orders/43/self_approve")
}

@Test func typedCommandDecodesArguments() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.typed-command"))
    let recorder = Recorder<[String]>()

    router.command(BanCommand.self) { _, _, command in
        await recorder.record([command.userID, command.reason ?? ""])
    }

    await router.handle()
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

@Test func typedCommandCanHandleItself() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.typed-command.self"))

    await SelfHandlingBanCommand.recorder.reset()
    router.command(SelfHandlingBanCommand.self)

    await router.handle()
    await router.process([makeCommandUpdate(text: "/self_ban 77")])

    let values = await SelfHandlingBanCommand.recorder.waitForCount(1)
    #expect(values == ["77"])
}

@Test func typedCallbackDecodesAndRendersParameters() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.typed-callback"))
    let recorder = Recorder<String>()

    router.callback(ApproveOrderCallback.self) { _, _, callback in
        await recorder.record(callback.orderID)
    }

    let data = try router.callbackData(for: ApproveOrderCallback(orderID: "42"))
    await router.handle()
    await router.process([makeCallbackUpdate(data: data)])

    let button = try router.callbackButton("Approve", callback: ApproveOrderCallback(orderID: "green tea"))
    let values = await recorder.waitForCount(1)

    #expect(values == ["42"])
    #expect(button.callbackData == "orders/green%20tea/approve")
}

@Test func typedCallbackCanHandleItself() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.typed-callback.self"))

    await SelfHandlingApproveOrderCallback.recorder.reset()
    router.callback(SelfHandlingApproveOrderCallback.self)

    await router.handle()
    await router.process([makeCallbackUpdate(data: "orders/55/self_approve")])

    let values = await SelfHandlingApproveOrderCallback.recorder.waitForCount(1)
    #expect(values == ["55"])
}

@Test func routeCollectionMountsRoutesIntoGroup() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.collection"))
    let recorder = Recorder<String>()

    router.group("admin") { admin in
        admin.add(collection: AdminCollection(recorder: recorder))
    }

    await router.handle()
    await router.process([makeCommandUpdate(text: "/admin_ban 42")])

    let values = await recorder.waitForCount(1)
    #expect(values == ["ban:42"])
}

@Test func groupedCollectionOwnsItsPath() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.grouped-collection"))
    let recorder = Recorder<String>()

    router.group(GroupedAdminCollection(recorder: recorder))

    await router.handle()
    await router.process([makeCommandUpdate(text: "/admin_ban 42")])

    let values = await recorder.waitForCount(1)
    #expect(values == ["grouped-ban:42"])
}

@Test func commandGuardsAllowContextSpecificRouting() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.guard.command"))
    let recorder = Recorder<String>()

    router.command("start", routeGuard: ChatTypeGuard(.group)) { _, _ in
        await recorder.record("group")
    }
    router.command("start", routeGuard: ChatTypeGuard(.private)) { _, _ in
        await recorder.record("private")
    }

    await router.handle()
    await router.process([makeCommandUpdate(text: "/start", chatType: .private)])

    let values = await recorder.waitForCount(1)
    #expect(values == ["private"])
}

@Test func callbackGuardsAllowContextSpecificRouting() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.guard.callback"))
    let recorder = Recorder<String>()

    router.callback("orders/{id}/approve", routeGuard: ChatTypeGuard(.group)) { _, _ in
        await recorder.record("group")
    }
    router.callback("orders/{id}/approve", routeGuard: ChatTypeGuard(.private)) { _, context in
        await recorder.record(try context.parameters.require("id"))
    }

    await router.handle()
    await router.process([makeCallbackUpdate(data: "orders/42/approve", chatType: .private)])

    let values = await recorder.waitForCount(1)
    #expect(values == ["42"])
}

@Test func middlewareWrapsHandlerExecution() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.middleware"))
    let recorder = Recorder<[String]>()

    router.command(
        "start",
        middlewares: [RecordingMiddleware(recorder: recorder, label: "mw")]
    ) { _, _ in
        await recorder.record(["handler"])
    }

    await router.handle()
    await router.process([makeCommandUpdate(text: "/start")])

    let values = await recorder.waitForCount(3)
    #expect(values == [["mw:before"], ["handler"], ["mw:after"]])
}

@Test func throttleMiddlewareDropsRepeatedUpdatesWithinInterval() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.middleware.throttle"))
    let recorder = Recorder<String>()

    router.command(
        "tap",
        middlewares: [
            TelerouteThrottleMiddleware(
                interval: .milliseconds(200),
                scope: .chatUser
            )
        ]
    ) { _, context in
        await recorder.record(context.command?.arguments.first ?? "")
    }

    await router.handle()
    await router.process([makeCommandUpdate(text: "/tap first", updateId: 220)])
    let values = await recorder.waitForCount(1, retries: 100)
    await router.process([makeCommandUpdate(text: "/tap second", updateId: 221)])
    try? await Task.sleep(for: .milliseconds(100))

    #expect(values == ["first"])
    #expect(await recorder.values == ["first"])
}

@Test func throttleMiddlewareConsumesDroppedUpdateBeforeFallbackRoute() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.middleware.throttle.consume"))
    let recorder = Recorder<String>()

    router.command(
        "tap",
        middlewares: [
            TelerouteThrottleMiddleware(
                interval: .milliseconds(200),
                scope: .chatUser
            )
        ]
    ) { _, context in
        await recorder.record("limited:\(context.command?.arguments.first ?? "")")
    }

    router.command("tap") { _, context in
        await recorder.record("fallback:\(context.command?.arguments.first ?? "")")
    }

    await router.handle()
    await router.process([makeCommandUpdate(text: "/tap first", updateId: 222)])
    _ = await recorder.waitForCount(1, retries: 100)
    await router.process([makeCommandUpdate(text: "/tap second", updateId: 223)])
    try? await Task.sleep(for: .milliseconds(100))

    #expect(await recorder.values == ["limited:first"])
}

@Test func debounceMiddlewareHandlesLatestUpdateAfterQuietInterval() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.middleware.debounce"))
    let recorder = Recorder<String>()

    router.command(
        "search",
        middlewares: [
            TelerouteDebounceMiddleware(
                interval: .milliseconds(50),
                scope: .chatUser
            )
        ]
    ) { _, context in
        await recorder.record(context.command?.arguments.first ?? "")
    }

    await router.handle()
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
    let router = Teleroute(bot: bot, logger: .init(label: "router.middleware.debounce.consume"))
    let recorder = Recorder<String>()

    router.command(
        "search",
        middlewares: [
            TelerouteDebounceMiddleware(
                interval: .milliseconds(50),
                scope: .chatUser
            )
        ]
    ) { _, context in
        await recorder.record("debounced:\(context.command?.arguments.first ?? "")")
    }

    router.command("search") { _, context in
        await recorder.record("fallback:\(context.command?.arguments.first ?? "")")
    }

    await router.handle()
    await router.process([makeCommandUpdate(text: "/search first", updateId: 232)])
    try? await Task.sleep(for: .milliseconds(20))
    await router.process([makeCommandUpdate(text: "/search second", updateId: 233)])

    _ = await recorder.waitForCount(1, retries: 100)
    try? await Task.sleep(for: .milliseconds(80))

    #expect(await recorder.values == ["debounced:second"])
}

@Test func routerPublishesLifecycleEvents() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.events"))
    let recorder = Recorder<TelerouteEvent>()

    let collectionTask = Task {
        var iterator = router.events.makeAsyncIterator()
        while let event = await iterator.next() {
            await recorder.record(event)
            if await recorder.values.count >= 2 {
                break
            }
        }
    }

    router.command("events") { _, _ in }

    await router.handle()
    await router.process([makeCommandUpdate(text: "/events", updateId: 235)])

    let events = await recorder.waitForCount(2, retries: 100)
    collectionTask.cancel()

    #expect(events.contains { $0.kind == .received && $0.updateId == 235 })
    #expect(events.contains { $0.kind == .handled && $0.routeKind == .command && $0.routeName == "events" })
}

@Test func eventEmitterPreservesEmissionOrder() async throws {
    let emitter = TelerouteEventEmitter()
    let eventCount = 50
    let events = emitter.events

    let collectionTask = Task {
        var iterator = events.makeAsyncIterator()
        var updateIds: [Int] = []
        while updateIds.count < eventCount {
            guard let event = await iterator.next() else { break }
            updateIds.append(event.updateId)
        }
        return updateIds
    }

    for updateId in 0..<eventCount {
        emitter.emit(
            .init(
                kind: .received,
                routeKind: .command,
                routeName: nil,
                updateId: updateId,
                chatId: nil,
                userId: nil,
                errorDescription: nil
            )
        )
    }

    let updateIds = await collectionTask.value
    emitter.finish()

    #expect(updateIds == Array(0..<eventCount))
}

@Test func flowRoutesMessagesAndCallbacksByActiveStep() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.flow"))
    let recorder = Recorder<String>()

    router.add(flow: SignupFlow(recorder: recorder))

    await router.handle()
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
    let router = Teleroute(bot: bot, logger: .init(label: "router.flow.command"))
    let recorder = Recorder<String>()

    router.add(flow: SignupFlow(recorder: recorder))

    await router.handle()
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
    let router = Teleroute(bot: bot, logger: .init(label: "router.flow.serial"))
    let recorder = Recorder<String>()

    router.add(flow: SignupFlow(recorder: recorder))

    await router.handle()
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
    let router = Teleroute(bot: bot, logger: .init(label: "router.flow.callback-user"))
    let recorder = Recorder<String>()

    router.add(flow: SignupFlow(recorder: recorder))

    await router.handle()
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
    let router = Teleroute(bot: bot, logger: .init(label: "router.flow.cancel"))
    let recorder = Recorder<String>()

    router.add(flow: SignupFlow(recorder: recorder))
    router.command("help") { _, _ in
        await recorder.record("help")
    }

    await router.handle()
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
    let router = Teleroute(
        bot: bot,
        logger: .init(label: "router.flow.storage"),
        flowStorage: flowStorage
    )
    let key = TelerouteFlowKey(chatId: 1, userId: 1)

    router.add(flow: SignupFlow(recorder: Recorder<String>()))

    await router.handle()
    await router.process([makeCommandUpdate(text: "/signup")])

    let session = await flowStorage.waitForSession(for: key)
    #expect(session?.id == SignupFlow.id)
    #expect(session?.step == SignupFlow.Step.name.rawValue)
}

@Test func replayProtectionDeduplicatesRepeatedCommands() async throws {
    let bot = try await makeBot()
    let router = Teleroute(
        bot: bot,
        logger: .init(label: "router.replay.command"),
        flowStorage: TelerouteInMemoryFlowStorage(),
        replayProtectionStorage: TelerouteInMemoryReplayProtectionStorage(),
        replayProtectionTTL: .seconds(5)
    )
    let recorder = Recorder<String>()

    router.command("start") { _, _ in
        await recorder.record("start")
    }

    await router.handle()
    await router.process([makeCommandUpdate(text: "/start", updateId: 100)])
    await router.process([makeCommandUpdate(text: "/start", updateId: 101)])

    let values = await recorder.waitForCount(1)
    #expect(values == ["start"])
}

@Test func replayProtectionDeduplicatesRepeatedCallbacks() async throws {
    let bot = try await makeBot()
    let router = Teleroute(
        bot: bot,
        logger: .init(label: "router.replay.callback"),
        flowStorage: TelerouteInMemoryFlowStorage(),
        replayProtectionStorage: TelerouteInMemoryReplayProtectionStorage(),
        replayProtectionTTL: .seconds(5)
    )
    let recorder = Recorder<String>()

    router.callback("orders/{id}/approve") { _, context in
        await recorder.record(try context.parameters.require("id"))
    }

    await router.handle()
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
    let router = Teleroute(bot: bot, logger: .init(label: "router.queue.command"))
    let recorder = Recorder<String>()
    let probe = ConcurrencyProbe()

    router.command("sync", queueing: .chatUser) { _, context in
        let value = context.command?.arguments.first ?? "unknown"
        await recorder.record("start:\(value)")
        await probe.enter()
        try? await Task.sleep(for: .milliseconds(50))
        await probe.leave()
        await recorder.record("end:\(value)")
    }

    await router.handle()
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

@Test func typedCommandUsesQueueingDeclaredOnSpec() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.queue.typed-command"))
    let recorder = Recorder<String>()
    let probe = ConcurrencyProbe()

    router.command(QueuedCommand.self) { _, _, command in
        await recorder.record("start:\(command.value)")
        await probe.enter()
        try? await Task.sleep(for: .milliseconds(50))
        await probe.leave()
        await recorder.record("end:\(command.value)")
    }

    await router.handle()
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
    let router = Teleroute(bot: bot, logger: .init(label: "router.commands.visibility"))

    router.command(
        "start",
        description: "Start the bot"
    ) { _, _ in }
    router.command(
        "ban",
        description: "Ban a user",
        visibility: [.allGroupChats, .allChatAdministrators]
    ) { _, _ in }
    router.command(
        "start",
        description: "Start the bot",
        routeGuard: ChatTypeGuard(.private)
    ) { _, _ in }

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
    let router = Teleroute(bot: bot, logger: .init(label: "router.routes.duplicates"))

    router.command("start") { _, _ in }
    router.command("start") { _, _ in }
    router.callback("orders/{id}") { _, _ in }
    router.callback("orders/{id}") { _, _ in }

    let duplicates = router.duplicateRouteSignatures

    #expect(duplicates.map(\.kind) == [.command, .callback])
    #expect(duplicates.map(\.name) == ["start", "orders/{id}"])
}

@Test func guardedDuplicateRoutesAreNotReportedAsDuplicates() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.routes.guarded-duplicates"))

    router.command("start", routeGuard: ChatTypeGuard(.private)) { _, _ in }
    router.command("start", routeGuard: ChatTypeGuard(.group)) { _, _ in }

    #expect(router.duplicateRouteSignatures.isEmpty)
}

@Test func typedCommandPublishesUsingSpecVisibility() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.commands.typed-visibility"))

    router.command(VisibleCommand.self)

    let commandSets = try router.publishedCommandSets()

    #expect(commandSets.count == 1)
    #expect(commandSets[0].commands.map(\.command) == ["visible"])
    #expect(commandSets[0].commands.map(\.description) == ["Visible command"])
}

@Test func conflictingPublishedCommandDescriptionsThrow() async throws {
    let bot = try await makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "router.commands.duplicate"))

    router.command("start", description: "Start") { _, _ in }
    router.command("start", description: "Boot") { _, _ in }

    #expect(throws: TelerouteError.self) {
        _ = try router.publishedCommandSets()
    }
}

@Test func routerCanPublishExplicitCommands() async throws {
    let recorder = PublishedCommandsRecorder()
    let bot = try await makeBot(client: RecordingCommandsClient(recorder: recorder))
    let router = Teleroute(bot: bot, logger: .init(label: "router.commands.publish"))

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
    let bot = try await makeBot(client: RecordingCommandsClient(recorder: recorder))
    let router = Teleroute(bot: bot, logger: .init(label: "router.commands.context-publish"))

    router.command("start") { _, context in
        try await context.publishCommands(
            [("profile", "Open profile")],
            visibility: .chat(.id(1))
        )
    }

    await router.handle()
    await router.process([makeCommandUpdate(text: "/start", updateId: 400)])

    let params = try await recorder.waitForCount(1).first.unwrap()
    #expect(params.commands.map(\.command) == ["profile"])
    #expect(scopeKey(params.scope) == "chat:1")
}

@Test func routerCanPublishTypedCommands() async throws {
    let recorder = PublishedCommandsRecorder()
    let bot = try await makeBot(client: RecordingCommandsClient(recorder: recorder))
    let router = Teleroute(bot: bot, logger: .init(label: "router.commands.publish.typed"))

    try await router.publishCommands([VisibleCommand.self])

    let params = try await recorder.waitForCount(1).first.unwrap()
    #expect(params.commands.map(\.command) == ["visible"])
    #expect(params.commands.map(\.description) == ["Visible command"])
    #expect(scopeKey(params.scope) == "allPrivateChats")
}

@Test func contextCanPublishTypedCommands() async throws {
    let recorder = PublishedCommandsRecorder()
    let bot = try await makeBot(client: RecordingCommandsClient(recorder: recorder))
    let router = Teleroute(bot: bot, logger: .init(label: "router.commands.context-publish.typed"))

    router.command("start") { _, context in
        try await context.publishCommands([VisibleCommand.self], visibility: .chat(.id(1)))
    }

    await router.handle()
    await router.process([makeCommandUpdate(text: "/start", updateId: 401)])

    let params = try await recorder.waitForCount(1).first.unwrap()
    #expect(params.commands.map(\.command) == ["visible"])
    #expect(params.commands.map(\.description) == ["Visible command"])
    #expect(scopeKey(params.scope) == "chat:1")
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

private struct SelfHandlingBanCommand: TelerouteCommand {
    static let path = "self_ban"
    static let recorder = Recorder<String>()

    let userID: String

    init(command: TelerouteCommandMatch) throws {
        self.userID = try command.require("userID")
    }

    func handle(update: TGUpdate, context: TelerouteContext) async throws {
        await Self.recorder.record(self.userID)
    }
}

private struct QueuedCommand: TelerouteCommand {
    static let path = "queued"
    static let queueing: TelerouteCommandQueueing? = .chatUser

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

private struct SelfHandlingApproveOrderCallback: TelerouteCallback {
    static let path = "orders/{orderID}/self_approve"
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

    func handle(update: TGUpdate, context: TelerouteContext) async throws {
        await Self.recorder.record(self.orderID)
    }
}

private struct AdminCollection: TelerouteCollectionBuilder {
    let recorder: Recorder<String>

    func boot(collection: TelerouteCollectionGroup) {
        collection.command("ban") { _, context in
            await self.recorder.record("ban:\(context.command?.arguments.first ?? "")")
        }
    }
}

private struct GroupedAdminCollection: TelerouteGroupCollection {
    let recorder: Recorder<String>

    let path = "admin"

    func boot(collection: TelerouteCollectionGroup) {
        collection.command("ban") { _, context in
            await self.recorder.record("grouped-ban:\(context.command?.arguments.first ?? "")")
        }
    }
}

private struct ChatTypeGuard: TelerouteGuard {
    let expected: TGChatType

    init(_ expected: TGChatType) {
        self.expected = expected
    }

    func matches(_ context: TelerouteContext) async throws -> Bool {
        context.message?.chat.type == self.expected
    }
}

private struct RecordingMiddleware: TelerouteMiddleware {
    let recorder: Recorder<[String]>
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
        flow.start("signup", at: .name) { _, _ in
            await self.recorder.record("start")
        }

        flow.message(at: .name) { _, context in
            let name = context.message?.text ?? ""
            await self.recorder.record("name:\(name)")
            try await context.transition(to: .confirm, merging: ["name": name])
        }

        flow.command("cancel", at: .confirm) { _, context in
            let name = try context.values.require("name")
            await self.recorder.record("cancel:\(name)")
            try await context.finish()
        }

        flow.callback("confirm/{decision}", at: .confirm) { _, context in
            let name = try context.values.require("name")
            let decision = try context.parameters.require("decision")
            await self.recorder.record("confirm:\(name):\(decision)")
            try await context.finish()
        }
    }
}

private struct TestClient: TGClientPrtcl {
    func post<Params: Encodable, Response: Decodable>(
        _ url: URL,
        params: Params?,
        as mediaType: HTTPMediaType?
    ) async throws -> Response {
        throw TestError.unexpectedNetworkCall
    }

    func post<Response: Decodable>(_ url: URL) async throws -> Response {
        throw TestError.unexpectedNetworkCall
    }
}

private struct RecordingCommandsClient: TGClientPrtcl {
    let recorder: PublishedCommandsRecorder

    func post<Params: Encodable, Response: Decodable>(
        _ url: URL,
        params: Params?,
        as mediaType: HTTPMediaType?
    ) async throws -> Response {
        guard url.absoluteString.contains("setMyCommands"),
              let params else {
            throw TestError.unexpectedClientCall
        }

        let data = try JSONEncoder().encode(params)
        let decoded = try JSONDecoder().decode(DecodedSetMyCommandsParams.self, from: data)
        await self.recorder.record(decoded)

        guard Response.self == Bool.self else {
            throw TestError.unexpectedClientCall
        }
        return true as! Response
    }

    func post<Response: Decodable>(_ url: URL) async throws -> Response {
        throw TestError.unexpectedClientCall
    }
}

private struct DecodedSetMyCommandsParams: Decodable {
    let commands: [TGBotCommand]
    let scope: RawScope?
    let languageCode: String?

    private enum CodingKeys: String, CodingKey {
        case commands
        case scope
        case languageCode = "language_code"
    }

    struct RawScope: Decodable {
        let type: String
        let chatId: TGChatId?
        let userId: Int64?

        private enum CodingKeys: String, CodingKey {
            case type
            case chatId = "chat_id"
            case userId = "user_id"
        }
    }
}

private func makeBot() async throws -> TGBot {
    try await SharedTestBot.make()
}

private func makeBot<Client: TGClientPrtcl>(client: Client) async throws -> TGBot {
    try await TGBot(
        connectionType: .longpolling(),
        tgClient: client,
        botId: "123456:test-token",
        log: .init(label: "tests.bot.custom")
    )
}

private actor SharedTestBot {
    static let shared = SharedTestBot()

    private var bot: TGBot?

    func get() async throws -> TGBot {
        if let bot = self.bot {
            return bot
        }

        let bot = try await TGBot(
            connectionType: .longpolling(),
            tgClient: TestClient(),
            botId: "123456:test-token",
            log: .init(label: "tests.bot")
        )
        self.bot = bot
        return bot
    }

    static func make() async throws -> TGBot {
        try await Self.shared.get()
    }
}

private func makeCommandUpdate(
    text: String,
    chatType: TGChatType = .private,
    userId: Int64 = 1,
    chatId: Int64 = 1,
    updateId: Int = 1
) -> TGUpdate {
    let commandToken = String(text.split(maxSplits: 1, whereSeparator: \.isWhitespace).first ?? "")
    let entity = TGMessageEntity(
        type: .botCommand,
        offset: 0,
        length: commandToken.utf16.count
    )
    let message = TGMessage(
        messageId: 1,
        from: makeUser(id: userId),
        date: 0,
        chat: makeChat(id: chatId, type: chatType),
        text: text,
        entities: [entity]
    )
    return TGUpdate(updateId: updateId, message: message)
}

private func makeMessageUpdate(
    text: String,
    chatType: TGChatType = .private,
    userId: Int64 = 1,
    chatId: Int64 = 1,
    updateId: Int = 3
) -> TGUpdate {
    let message = TGMessage(
        messageId: 3,
        from: makeUser(id: userId),
        date: 0,
        chat: makeChat(id: chatId, type: chatType),
        text: text
    )
    return TGUpdate(updateId: updateId, message: message)
}

private func makeCallbackUpdate(
    data: String,
    chatType: TGChatType = .private,
    messageUserId: Int64 = 1,
    messageIsBot: Bool = false,
    callbackUserId: Int64 = 1,
    chatId: Int64 = 1,
    updateId: Int = 2
) -> TGUpdate {
    let message = TGMessage(
        messageId: 1,
        from: makeUser(id: messageUserId, isBot: messageIsBot),
        date: 0,
        chat: makeChat(id: chatId, type: chatType),
        text: "callback host"
    )
    let callbackQuery = TGCallbackQuery(
        id: "callback-id",
        from: makeUser(id: callbackUserId),
        message: .message(message),
        chatInstance: "chat-instance",
        data: data
    )
    return TGUpdate(updateId: updateId, callbackQuery: callbackQuery)
}

private func makeUser(id: Int64 = 1, isBot: Bool = false) -> TGUser {
    TGUser(id: id, isBot: isBot, firstName: "Test", username: "tester")
}

private func makeChat(id: Int64 = 1, type: TGChatType = .private) -> TGChat {
    TGChat(id: id, type: type, firstName: "Test")
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
        case let .chat(id):
            return "chat:\(id)"
        case let .username(username):
            return "chat:\(username)"
        case .undefined, nil:
            return "chat:undefined"
        }
    case "chat_administrators":
        switch scope.chatId {
        case let .chat(id):
            return "chatAdministrators:\(id)"
        case let .username(username):
            return "chatAdministrators:\(username)"
        case .undefined, nil:
            return "chatAdministrators:undefined"
        }
    case "chat_member":
        let chat: String
        switch scope.chatId {
        case let .chat(id):
            chat = "\(id)"
        case let .username(username):
            chat = username
        case .undefined, nil:
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
