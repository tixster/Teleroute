import Testing
import Teleroute
import TelerouteTestSupport

@Test func botRunsBotIndependentRouterAndResponseHandlers() async throws {
    let router = Teleroute()
    router.command("hello") { context in
        .reply("Hello from update \(context.update.updateId)")
    }

    let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(
        router: router
    )

    try await bot.test { client in
        let result = await client.sendCommand("hello", updateId: 1_001)
        #expect(result.events.map(\.kind) == [.received, .handled])
        #expect(result.terminalEvent?.routeName == "hello")
    }

    let effects = telegram.effects
    #expect(effects.count == 1)
    guard case let .sentMessage(message) = effects[0] else {
        Issue.record("Expected a sent message")
        await bot.shutdown()
        return
    }
    #expect(message.text == "Hello from update 1001")
    await bot.shutdown()
}

@Test func typedMiddlewareCanTransformCustomContext() async throws {
    let router = Teleroute(context: PublicAppContext.self)
    router.middlewares.add(PublicPrefixMiddleware(prefix: "root"))
    router.command("context") { context in
        .reply("\(context.prefix):\(context.coreContext.userId ?? -1)")
    }

    let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(
        router: router
    )
    try await bot.test { client in
        let result = await client.sendCommand("context", userId: 42, updateId: 1_002)
        #expect(result.terminalEvent?.kind == .handled)
    }

    guard case let .some(.sentMessage(message)) = telegram.effects.first else {
        Issue.record("Expected a sent message")
        await bot.shutdown()
        return
    }
    #expect(message.text == "root:42")
    await bot.shutdown()
}

@Test func childContextRefinesParentContextForNestedGroup() async throws {
    let router = Teleroute(context: PublicAppContext.self)
    router.middlewares.add(PublicPrefixMiddleware(prefix: "inherited"))
    router.group("admin", context: PublicAdminContext.self) { admin in
        admin.command("status") { context in
            .reply("\(context.prefix):admin-\(context.userId)")
        }
    }

    let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(
        router: router
    )
    try await bot.test { client in
        let result = await client.sendCommand(
            "admin_status",
            userId: 7,
            updateId: 1_003
        )
        #expect(result.terminalEvent?.kind == .handled)
    }

    guard case let .some(.sentMessage(message)) = telegram.effects.first else {
        Issue.record("Expected a sent message")
        await bot.shutdown()
        return
    }
    #expect(message.text == "inherited:admin-7")
    await bot.shutdown()
}

@Test func routeCollectionExportsTypedCallbackHandle() throws {
    let router = Teleroute()
    let exports = router.addRoutes(PublicOrderRoutes())
    let button = exports.reject.button(
        PublicRejectOrder(orderId: "42"),
        "Reject"
    )

    #expect(try router.render(button).callbackData == "orders/reject/42")
    #expect(try router.publishedCommandSets().count == 1)
}

@Test func typedMiddlewareCanShortCircuitWithResponse() async throws {
    let recorder = TelerouteTestRecorder<Bool>()
    let router = Teleroute()
    router.middlewares.add(PublicBlockingMiddleware())
    router.command("blocked") { _ in
        await recorder.record(true)
        return .none
    }

    let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(
        router: router
    )
    try await bot.test { client in
        let result = await client.sendCommand("blocked", updateId: 1_004)
        #expect(result.terminalEvent?.kind == .handled)
    }

    #expect(await recorder.values.isEmpty)
    guard case let .some(.sentMessage(message)) = telegram.effects.first else {
        Issue.record("Expected middleware response")
        await bot.shutdown()
        return
    }
    #expect(message.text == "blocked by middleware")
    await bot.shutdown()
}

@Test func botStartSyncsMenusAndLifecycleIsIdempotent() async throws {
    let router = Teleroute()
    router.command("menu", description: "Show menu") { _ in .none }

    let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(
        router: router,
        configuration: .init(
            replayProtectionStorage: nil,
            syncPublishedCommandsOnStart: true
        ),
        label: "public.bot.lifecycle"
    )

    try await bot.start()
    try await bot.start()
    #expect(
        telegram.effects.filter {
            if case .commandMenuUpdated = $0 { return true }
            return false
        }.count == 1
    )

    await bot.shutdown()
    await #expect(throws: TelerouteBotError.stopped) {
        try await bot.start()
    }
}

@Test func callbackResponseSequenceRecordsAnswerAndEdit() async throws {
    let router = Teleroute()
    let route = router.callback(PublicRejectOrder.self) { callback, _ in
        .sequence([
            .answerCallback("Rejected \(callback.orderId)"),
            .edit("Order \(callback.orderId) rejected"),
        ])
    }
    let data = try route.callbackData(for: .init(orderId: "42"))
    let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(
        router: router
    )

    try await bot.test { client in
        let result = await client.pressCallback(data, updateId: 1_005)
        #expect(result.terminalEvent?.kind == .handled)
    }

    #expect(telegram.effects.count == 2)
    guard case let .answeredCallback(answer) = telegram.effects[0],
          case let .editedMessage(edit) = telegram.effects[1] else {
        Issue.record("Expected callback answer followed by message edit")
        await bot.shutdown()
        return
    }
    #expect(answer.text == "Rejected 42")
    #expect(edit.text == "Order 42 rejected")
    await bot.shutdown()
}

@Test func typedMiddlewareAlsoWrapsFlowRoutes() async throws {
    let flowStorage = TelerouteMockFlowStorage()
    let router = Teleroute()
    router.middlewares.add(PublicBlockingMiddleware())
    router.flow(PublicBlockedFlow())

    let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(
        router: router,
        configuration: .init(
            flowStorage: flowStorage,
            replayProtectionStorage: nil
        )
    )
    try await bot.test { client in
        let result = await client.sendCommand("begin", updateId: 1_006)
        #expect(result.terminalEvent?.kind == .handled)
    }

    #expect(await flowStorage.count == 0)
    guard case let .some(.sentMessage(message)) = telegram.effects.first else {
        Issue.record("Expected middleware response")
        await bot.shutdown()
        return
    }
    #expect(message.text == "blocked by middleware")
    await bot.shutdown()
}

@Test func botRunShutsDownWhenCancelled() async throws {
    let router = Teleroute()
    let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
        router: router,
        label: "public.bot.run"
    )

    let task = Task {
        try await bot.run()
    }
    task.cancel()
    try await task.value

    await #expect(throws: TelerouteBotError.stopped) {
        try await bot.start()
    }
}

private struct PublicAppContext: TelerouteInitializableRequestContext {
    let coreContext: TelerouteContext
    var prefix = "unset"

    init(source: TelerouteContextSource) {
        self.coreContext = source.coreContext
    }
}

private struct PublicPrefixMiddleware: TelerouteMiddleware {
    typealias Context = PublicAppContext

    let prefix: String

    func handle(
        _ context: PublicAppContext,
        next: @escaping @Sendable (PublicAppContext) async throws -> TelerouteResponse
    ) async throws -> TelerouteResponse {
        var context = context
        context.prefix = self.prefix
        return try await next(context)
    }
}

private struct PublicBlockingMiddleware: TelerouteMiddleware {
    typealias Context = TelerouteContext

    func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> TelerouteResponse
    ) async throws -> TelerouteResponse {
        .reply("blocked by middleware")
    }
}

private struct PublicAdminContext: TelerouteChildRequestContext {
    typealias ParentContext = PublicAppContext

    let coreContext: TelerouteContext
    let prefix: String
    let userId: Int64

    init(context: PublicAppContext) throws {
        guard let userId = context.coreContext.userId else {
            throw PublicContextError.userMissing
        }
        self.coreContext = context.coreContext
        self.prefix = context.prefix
        self.userId = userId
    }
}

private enum PublicContextError: Error {
    case userMissing
}

private struct PublicBlockedFlow: TelerouteFlow {
    enum Step: String, Sendable {
        case active
    }

    func boot(flow: TelerouteFlowGroup<Self>) {
        flow.start("begin", at: .active) { _ in }
    }
}

private struct PublicRejectOrder: TelerouteCallback {
    static let path = "reject/{orderId}"

    let orderId: String

    init(orderId: String) {
        self.orderId = orderId
    }

    init(parameters: TelerouteParameters) throws {
        self.orderId = try parameters.require("orderId")
    }

    var parameters: [String: String] {
        ["orderId": self.orderId]
    }
}

private struct PublicOrderRoutes: TelerouteRouteCollection {
    struct Exports: Sendable {
        let reject: TelerouteCallbackRoute<PublicRejectOrder>
    }

    func addRoutes(
        to routes: TelerouteRouterGroup<TelerouteContext>
    ) -> Exports {
        let orders = routes.group("orders")
        orders.command(
            "list",
            description: "List orders"
        ) { _ in }
        let reject = orders.callback(PublicRejectOrder.self) { _, _ in }
        return .init(reject: reject)
    }
}
