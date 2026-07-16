import Testing
import Teleroute
import TelerouteTestSupport

@Test func externalCodeCanCreateFlowSessionForCustomStorage() {
    let session = TelerouteFlowSession(
        id: "SignupFlow",
        step: "name",
        values: .init(["name": "Alice"])
    )

    #expect(session.id == "SignupFlow")
    #expect(session.step == "name")
    #expect(session.values["name"] == "Alice")
}

@Test func legacyCustomStorageReceivesDefaultSessionMutationAPI() async throws {
    let storage = PublicLegacyFlowStorage()
    let key = TelerouteFlowKey(chatId: 1, userId: 2)

    await storage.setSession(
        .init(id: "flow", step: "one", values: .init(["first": "1"])),
        for: key
    )
    let updated = await storage.updateSession(for: key) { current in
        .init(
            id: current?.id ?? "flow",
            step: "two",
            values: .init((current?.values.dictionary ?? [:]).merging(["second": "2"]) { _, new in new })
        )
    }

    #expect(updated?.step == "two")
    #expect(updated?.values["first"] == "1")
    #expect(updated?.values["second"] == "2")
}

@Test func publicTypedCallbackRoutesBindButtonsToTheirRegistrationScope() async throws {
    let bot = try await TelerouteTestSupport.makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "public.keyboard.throwing"))
    let rootRoute = router.callback(PublicV2Callback.self) { _, _ in }
    let nestedRoute = router.group("nested").callback(PublicV2Callback.self) { _, _ in }
    let callback = PublicV2Callback(value: "42")
    let description = rootRoute.button(callback, "Open", style: "primary")
    let pagination = TeleroutePagination.navigationRow(rootRoute, page: 0, pageCount: 2) { page in
        PublicV2Callback(value: "page-\(page)")
    }

    let keyboard = try router.keyboard([[description], pagination])
    let button = try router.render(description)
    let nestedButton = try router.render(
        nestedRoute.button(PublicV2Callback(value: "nested"), "Nested")
    )

    #expect(keyboard.inlineKeyboard[0][0].callbackData == "public/42")
    #expect(keyboard.inlineKeyboard[1][0].callbackData == "public/page-1")
    #expect(button.callbackData == "public/42")
    #expect(button.style == "primary")
    #expect(nestedButton.callbackData == "nested/public/nested")
    #expect(try rootRoute.callbackData(for: callback) == "public/42")
    router.shutdown()
}

@Test func publicTypedButtonsRejectMissingScopesAndForeignRouters() async throws {
    let bot = try await TelerouteTestSupport.makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "public.keyboard.validation"))
    let callback = PublicV2Callback(value: "42")

    #expect {
        try router.render(callback.button("Unregistered"))
    } throws: { error in
        guard let error = error as? TelerouteError,
              case let .callbackRouteNotRegistered(path) = error else {
            return false
        }
        return path == "public/{value}"
    }

    let route = router.callback(
        PublicV2Callback.self,
        guards: [TeleroutePrivateChatGuard()]
    ) { _, _ in }
    #expect(try router.render(callback.button("Registered")).callbackData == "public/42")

    #expect {
        try router.group("nested").render(callback.button("Wrong scope"))
    } throws: { error in
        guard let error = error as? TelerouteError,
              case let .callbackRouteNotRegistered(path) = error else {
            return false
        }
        return path == "nested/public/{value}"
    }

    let otherBot = try await TelerouteTestSupport.makeBot()
    let otherRouter = Teleroute(bot: otherBot, logger: .init(label: "public.keyboard.foreign"))
    #expect {
        try otherRouter.render(route.button(callback, "Foreign"))
    } throws: { error in
        guard let error = error as? TelerouteError,
              case let .callbackRouteRouterMismatch(path) = error else {
            return false
        }
        return path == "public/{value}"
    }

    router.shutdown()
    otherRouter.shutdown()
}

@Test func publicMacrosExposeMemberwiseInitializers() {
    let command = PublicOptionalCommand(value: nil)
    let callback = PublicOptionalCallback(value: "42")

    #expect(command.value == nil)
    #expect(callback.parameters == ["value": "42"])
}

@Test func publicRootSurfaceRegistersEveryRouteKindAndBuildsCallbacks() async throws {
    let bot = try await TelerouteTestSupport.makeBot()
    let recorder = TelerouteTestRecorder<String>()
    let router = Teleroute(
        bot: bot,
        logger: .init(label: "public.v2"),
        configuration: .init(replayProtectionStorage: nil)
    )

    router.command("raw", queue: .perChat) { context in
        await recorder.record("raw:\(context.update.updateId)")
    }
    router.command(PublicV2Command.self) { command, _ in
        await recorder.record("typed:\(command.value)")
    }
    router.callback(PublicV2Callback.self) { callback, _ in
        await recorder.record("callback:\(callback.value)")
    }
    router.group("nested").command("ping") { _ in
        await recorder.record("nested")
    }
    router.mount(PublicV2Module(recorder: recorder))
    router.flow(PublicV2Flow())

    let callback = PublicV2Callback(value: "7")
    #expect(try router.callbackData(for: callback) == "public/7")
    #expect(try router.callbackData(for: PublicV2Callback(value: "8")) == "public/8")
    #expect(try router.render(callback.button("Open")).callbackData == "public/7")

    router.command("duplicate") { _ in }
    router.command("duplicate") { _ in }
    #expect(router.duplicateRouteSignatures.count == 1)

    await router.handle()
    await router.process([
        TelerouteTestSupport.makeCommandUpdate(text: "/raw", updateId: 900),
        TelerouteTestSupport.makeCommandUpdate(text: "/typed value", updateId: 901),
        TelerouteTestSupport.makeCallbackUpdate(data: "public/42", updateId: 902),
        TelerouteTestSupport.makeCommandUpdate(text: "/module_ping", updateId: 903),
        TelerouteTestSupport.makeCommandUpdate(text: "/nested_ping", updateId: 904),
    ])

    let values = await recorder.waitForCount(5, retries: 100)
    #expect(Set(values) == ["raw:900", "typed:value", "callback:42", "module", "nested"])
    router.shutdown()
}

@Test func publicHandlingTypedRoutesWorkAtRootAndInNestedScopes() async throws {
    await PublicHandlingCommand.recorder.reset()
    await PublicHandlingCallback.recorder.reset()

    let bot = try await TelerouteTestSupport.makeBot()
    let router = Teleroute(
        bot: bot,
        logger: .init(label: "public.self-handling"),
        configuration: .init(replayProtectionStorage: nil)
    )

    router.command(PublicHandlingCommand.self)
    router.callback(PublicHandlingCallback.self)

    let nested = router.group("nested")
    nested.command(PublicHandlingCommand.self)
    nested.callback(PublicHandlingCallback.self)

    await router.handle()
    await router.process([
        TelerouteTestSupport.makeCommandUpdate(text: "/self_handled root", updateId: 910),
        TelerouteTestSupport.makeCommandUpdate(text: "/nested_self_handled nested", updateId: 911),
        TelerouteTestSupport.makeCallbackUpdate(data: "self/12", updateId: 912),
        TelerouteTestSupport.makeCallbackUpdate(data: "nested/self/34", updateId: 913),
    ])

    let commands = await PublicHandlingCommand.recorder.waitForCount(2, retries: 100)
    let callbacks = await PublicHandlingCallback.recorder.waitForCount(2, retries: 100)
    #expect(Set(commands) == ["root:910", "nested:911"])
    #expect(Set(callbacks) == ["12:912", "34:913"])
    router.shutdown()
}

@Test func publicAttachRegistersOnceAndConnectsTheBotPipeline() async throws {
    let bot = try await TelerouteTestSupport.makeBot()
    let recorder = TelerouteTestRecorder<Int>()
    let router = Teleroute(
        bot: bot,
        logger: .init(label: "public.attach"),
        configuration: .init(replayProtectionStorage: nil)
    )

    router.command("ping") { context in
        await recorder.record(context.update.updateId)
    }

    try await withThrowingTaskGroup(of: Void.self) { group in
        for _ in 0..<8 {
            group.addTask {
                try await router.attach()
            }
        }
        try await group.waitForAll()
    }

    let dispatchers = await bot.dispatchers
    #expect(dispatchers.count == 1)
    #expect((dispatchers.first as? Teleroute) === router)

    await bot.processing(updates: [
        TelerouteTestSupport.makeCommandUpdate(text: "/ping", updateId: 904),
    ])

    #expect(await recorder.waitForCount(1) == [904])
    router.shutdown()
}

@Test func publicEventStreamAcceptsPerSubscriberBuffering() async throws {
    let bot = try await TelerouteTestSupport.makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "public.events"))
    let stream = router.eventStream(buffering: .oldest(8))
    var iterator = stream.makeAsyncIterator()

    router.shutdown()
    #expect(await iterator.next() == nil)
}

private actor PublicLegacyFlowStorage: TelerouteFlowStorage {
    private var sessions: [TelerouteFlowKey: TelerouteFlowSession] = [:]

    func session(for key: TelerouteFlowKey) -> TelerouteFlowSession? {
        self.sessions[key]
    }

    func setSession(_ session: TelerouteFlowSession, for key: TelerouteFlowKey) {
        self.sessions[key] = session
    }

    func removeSession(for key: TelerouteFlowKey) {
        self.sessions[key] = nil
    }
}

@TelerouteCommand("optional")
private struct PublicOptionalCommand {
    let value: String?
}

@TelerouteCallback("optional/{value}")
private struct PublicOptionalCallback {
    let value: String
}

private struct PublicV2Command: TelerouteCommand {
    static let path = "typed"
    let value: String

    init(command: TelerouteCommandMatch) throws {
        self.value = try command.require("value")
    }
}

private struct PublicV2Callback: TelerouteCallback {
    static let path = "public/{value}"
    let value: String

    init(value: String) {
        self.value = value
    }

    init(parameters: TelerouteParameters) throws {
        self.value = try parameters.require("value")
    }

    var parameters: [String: String] {
        ["value": self.value]
    }
}

private struct PublicHandlingCommand: TelerouteHandlingCommand {
    static let path = "self_handled"
    static let recorder = TelerouteTestRecorder<String>()

    let value: String

    init(command: TelerouteCommandMatch) throws {
        self.value = try command.require("value")
    }

    func handle(context: TelerouteContext) async throws {
        await Self.recorder.record("\(self.value):\(context.update.updateId)")
    }
}

private struct PublicHandlingCallback: TelerouteHandlingCallback {
    static let path = "self/{value}"
    static let recorder = TelerouteTestRecorder<String>()

    let value: String

    init(parameters: TelerouteParameters) throws {
        self.value = try parameters.require("value")
    }

    var parameters: [String: String] {
        ["value": self.value]
    }

    func handle(context: TelerouteContext) async throws {
        await Self.recorder.record("\(self.value):\(context.update.updateId)")
    }
}

private struct PublicV2Flow: TelerouteFlow {
    enum Step: String, Sendable {
        case ready
    }

    func boot(flow: TelerouteFlowGroup<Self>) {}
}

private struct PublicV2Module: TelerouteModule {
    let recorder: TelerouteTestRecorder<String>

    func register(in routes: TelerouteRoutes) {
        routes.group("module").command("ping") { _ in
            await self.recorder.record("module")
        }
    }
}
