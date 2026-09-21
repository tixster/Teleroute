import Testing
import Teleroute
import TelerouteMacros
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

@Test func publicConfigurationExposesUpdateConcurrencyLimit() {
    var configuration = TelerouteBot.Configuration(maximumConcurrentUpdates: 7)
    #expect(configuration.maximumConcurrentUpdates == 7)
    configuration.maximumConcurrentUpdates = 3
    #expect(configuration.maximumConcurrentUpdates == 3)
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
    let router = Teleroute()
    let rootRoute = router.callback(PublicV2Callback.self) { _, _ in }
    let nestedRoute = router.group("nested").callback(PublicV2Callback.self) { _, _ in }
    let callback = PublicV2Callback(value: "42")
    let description = rootRoute.button(callback, "Open", style: .primary)
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
    #expect(button.style == .primary)
    #expect(nestedButton.callbackData == "nested/public/nested")
    #expect(try rootRoute.callbackData(for: callback) == "public/42")
}

@Test func publicTypedButtonsRejectMissingScopesAndForeignRouters() async throws {
    let router = Teleroute()
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

    let otherRouter = Teleroute()
    #expect {
        try otherRouter.render(route.button(callback, "Foreign"))
    } throws: { error in
        guard let error = error as? TelerouteError,
              case let .callbackRouteRouterMismatch(path) = error else {
            return false
        }
        return path == "public/{value}"
    }

}

@Test func publicMacrosExposeMemberwiseInitializers() {
    let command = PublicOptionalCommand(value: nil)
    let callback = PublicOptionalCallback(value: "42")

    #expect(command.value == nil)
    #expect(callback.parameters == ["value": "42"])
}

@Test func publicRootSurfaceRegistersEveryRouteKindAndBuildsCallbacks() async throws {
    let bot = try TelerouteTestSupport.makeClient()
    let recorder = TelerouteTestRecorder<String>()
    let router = Teleroute()
    let telerouteBot = TelerouteBot(
        client: bot,
        router: router,
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
    let moduleRoutes = router.addRoutes(PublicV2Routes(recorder: recorder))
    router.flow(PublicV2Flow())

    let callback = PublicV2Callback(value: "7")
    #expect(try router.callbackData(for: callback) == "public/7")
    #expect(try router.callbackData(for: PublicV2Callback(value: "8")) == "public/8")
    #expect(try router.render(callback.button("Open")).callbackData == "public/7")
    #expect(
        try router.render(
            moduleRoutes.action.button(PublicV2Callback(value: "9"), "Module action")
        ).callbackData == "module/public/9"
    )

    router.command("duplicate") { _ in }
    router.command("duplicate") { _ in }
    #expect(router.duplicateRouteSignatures.count == 1)

    try await telerouteBot.test { client in
        _ = await client.execute([
            TelerouteTestSupport.makeCommandUpdate(text: "/raw", updateId: 900),
            TelerouteTestSupport.makeCommandUpdate(text: "/typed value", updateId: 901),
            TelerouteTestSupport.makeCallbackUpdate(data: "public/42", updateId: 902),
            TelerouteTestSupport.makeCommandUpdate(text: "/module_ping", updateId: 903),
            TelerouteTestSupport.makeCommandUpdate(text: "/nested_ping", updateId: 904),
            TelerouteTestSupport.makeCallbackUpdate(data: "module/public/9", updateId: 905),
        ])
    }

    let values = await recorder.waitForCount(6, retries: 100)
    #expect(Set(values) == ["raw:900", "typed:value", "callback:42", "module", "module:9", "nested"])
    await telerouteBot.shutdown()
}

@Test func publicHandlingTypedRoutesWorkAtRootAndInNestedScopes() async throws {
    await PublicHandlingCommand.recorder.reset()
    await PublicHandlingCallback.recorder.reset()

    let bot = try TelerouteTestSupport.makeClient()
    let router = Teleroute()
    let telerouteBot = TelerouteBot(
        client: bot,
        router: router,
        logger: .init(label: "public.self-handling"),
        configuration: .init(replayProtectionStorage: nil)
    )

    router.command(PublicHandlingCommand.self)
    router.callback(PublicHandlingCallback.self)

    let nested = router.group("nested")
    nested.command(PublicHandlingCommand.self)
    nested.callback(PublicHandlingCallback.self)

    try await telerouteBot.test { client in
        _ = await client.execute([
            TelerouteTestSupport.makeCommandUpdate(text: "/self_handled root", updateId: 910),
            TelerouteTestSupport.makeCommandUpdate(text: "/nested_self_handled nested", updateId: 911),
            TelerouteTestSupport.makeCallbackUpdate(data: "self/12", updateId: 912),
            TelerouteTestSupport.makeCallbackUpdate(data: "nested/self/34", updateId: 913),
        ])
    }

    let commands = await PublicHandlingCommand.recorder.waitForCount(2, retries: 100)
    let callbacks = await PublicHandlingCallback.recorder.waitForCount(2, retries: 100)
    #expect(Set(commands) == ["root:910", "nested:911"])
    #expect(Set(callbacks) == ["12:912", "34:913"])
    await telerouteBot.shutdown()
}

@Test func publicProcessConnectsTheBotPipeline() async throws {
    let bot = try TelerouteTestSupport.makeClient()
    let recorder = TelerouteTestRecorder<Int64>()
    let router = Teleroute()
    let telerouteBot = TelerouteBot(
        client: bot,
        router: router,
        logger: .init(label: "public.process"),
        configuration: .init(replayProtectionStorage: nil)
    )

    router.command("ping") { context in
        await recorder.record(context.update.updateId)
    }

    await telerouteBot.process([
        TelerouteTestSupport.makeCommandUpdate(text: "/ping", updateId: 904),
    ])

    #expect(await recorder.waitForCount(1) == [904])
    await telerouteBot.shutdown()
}

@Test func publicEventStreamAcceptsPerSubscriberBuffering() async throws {
    let bot = try TelerouteTestSupport.makeClient()
    let router = Teleroute()
    let telerouteBot = TelerouteBot(
        client: bot,
        router: router,
        logger: .init(label: "public.events")
    )
    let stream = telerouteBot.eventStream(buffering: .oldest(8))
    var iterator = stream.makeAsyncIterator()

    await telerouteBot.shutdown()
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

    func handle(context: TelerouteContext) async throws -> TelerouteResponse {
        await Self.recorder.record("\(self.value):\(context.update.updateId)")
        return .none
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

    func handle(context: TelerouteContext) async throws -> TelerouteResponse {
        await Self.recorder.record("\(self.value):\(context.update.updateId)")
        return .none
    }
}

private struct PublicV2Flow: TelerouteFlow {
    enum Step: String, Sendable {
        case ready
    }

    func boot(flow: TelerouteFlowGroup<Self>) {}
}

private struct PublicV2Routes: TelerouteRouteCollection {
    struct Exports: Sendable {
        let action: TelerouteCallbackRoute<PublicV2Callback>
    }

    let recorder: TelerouteTestRecorder<String>

    func addRoutes(
        to routes: TelerouteRouterGroup<TelerouteContext>
    ) -> Exports {
        let module = routes.group("module")
        module.command("ping") { _ in
            await self.recorder.record("module")
        }
        let action = module.callback(PublicV2Callback.self) { callback, _ in
            await self.recorder.record("module:\(callback.value)")
        }
        return .init(action: action)
    }
}

/// The generated model types must be reachable from a bare `import Teleroute`,
/// with no `import TelegramBotAPI` in sight.
///
/// This is the assertion guarding the `@_exported import TelegramBotAPI` in
/// `TelegramVocabulary.swift`. Before the move to flat names, 19 typealiases
/// did that job; if the re-export is ever dropped, every downstream file that
/// names `Message` or `Update` stops compiling, and this test is what catches
/// it first. Note the deliberate absence of a `TelegramBotAPI` import above.
@Test func publicModelTypesAreVisibleFromTelerouteAlone() {
    let chat = Chat(id: 1, type: .private)
    var message = Message(messageId: 10, date: 0, chat: chat, text: "hi")
    message.replyToMessage = Message(messageId: 9, date: 0, chat: chat)

    let update = Update(updateId: 1, message: message)
    #expect(update.kind == .message)
    #expect(update.message?.replyToMessage?.messageId == 9)

    let target: ChatId = .id(1)
    #expect(target.int64Value == 1)

    let markup: ReplyMarkup = .inline(InlineKeyboardMarkup(rows: []))
    guard case .InlineKeyboardMarkup = markup else {
        Issue.record("expected .InlineKeyboardMarkup, got \(markup)")
        return
    }

    let member: ChatMember = .member(ChatMemberMember(user: User(id: 7, isBot: false, firstName: "U")))
    guard case .member = member else {
        Issue.record("expected .member, got \(member)")
        return
    }

    // The sources say which Bot API revision they were generated from.
    #expect(!BotAPIVersion.version.isEmpty)
}
