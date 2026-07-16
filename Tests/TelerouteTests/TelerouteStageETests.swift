import Testing
@_spi(Testing) @testable import Teleroute
import TelerouteTestSupport
import SwiftTelegramBot

@Suite(.serialized)
struct TelerouteStageETests {
    @Test func keyboardDescriptionsRenderRows() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.keyboard.rows"))
        let items = router.callback(ItemCallback.self) { _, _ in }
        let keyboard = try router.keyboard([
            [
                items.button(ItemCallback(id: "a"), "A"),
                items.button(ItemCallback(id: "b"), "B"),
            ],
            [items.button(ItemCallback(id: "c"), "C")],
        ])

        #expect(keyboard.inlineKeyboard.count == 2)
        #expect(keyboard.inlineKeyboard[0].map(\.text) == ["A", "B"])
        #expect(keyboard.inlineKeyboard[1].map(\.text) == ["C"])
    }

    @Test func keyboardDescriptionsAcceptRawButtons() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.keyboard.raw"))
        let keyboard = try router.keyboard([[
            .raw(.init(text: "X", callbackData: "x")),
            .raw(.init(text: "Y", callbackData: "y")),
        ]])

        #expect(keyboard.inlineKeyboard.count == 1)
        #expect(keyboard.inlineKeyboard[0].map(\.text) == ["X", "Y"])
    }

    @Test func paginationNavigationRowHidesPrevOnFirstPage() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.keyboard.first-page"))
        let pages = router.callback(PageCallback.self) { _, _ in }
        let buttons = TeleroutePagination.navigationRow(pages, page: 0, pageCount: 3) {
            PageCallback(page: $0)
        }
        let keyboard = try router.keyboard([buttons])

        #expect(buttons.count == 1)
        #expect(keyboard.inlineKeyboard.first?.first?.text == "Next ▶︎")
        #expect(keyboard.inlineKeyboard.first?.first?.callbackData == "list/1")
    }

    @Test func paginationNavigationRowHidesNextOnLastPage() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.keyboard.last-page"))
        let pages = router.callback(PageCallback.self) { _, _ in }
        let buttons = TeleroutePagination.navigationRow(pages, page: 2, pageCount: 3) {
            PageCallback(page: $0)
        }
        let keyboard = try router.keyboard([buttons])

        #expect(buttons.count == 1)
        #expect(keyboard.inlineKeyboard.first?.first?.text == "◀︎ Prev")
        #expect(keyboard.inlineKeyboard.first?.first?.callbackData == "list/1")
    }

    @Test func flowTypedCallbackRoutesAndBuildsButton() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.flow.typed-callback"))

        router.flow(TypedCallbackFlow())

        await router.handle()
        await router.process([TelerouteTestSupport.makeCommandUpdate(text: "/typed_flow", updateId: 700)])
        _ = await TypedCallbackFlow.recorder.waitForCount(1, retries: 100)

        // Button built with the typed flow API must produce callback data that
        // the registered typed callback route matches.
        let buttonData = try router.callbackData(
            for: ConfirmTypedCallback(decision: "yes")
        )
        await router.process([
            TelerouteTestSupport.makeCallbackUpdate(data: buttonData, updateId: 701),
        ])
        let confirmed = await TypedCallbackFlow.recorder.waitForCount(2, retries: 100)
        #expect(confirmed.contains("started:typed_confirm/yes"))
        #expect(confirmed.contains("confirmed:yes"))
    }

    @Test func metricsSinkReceivesHandledEventWithDuration() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let sink = RecordingMetricsSink()
        let router = TelerouteRuntime(
            bot: bot,
            logger: .init(label: "router.metrics"),
            configuration: .init(metricsSink: sink)
        )

        router.command("ping") { _ in
            try? await Task.sleep(for: .milliseconds(10))
        }

        await router.handle()
        await router.process([TelerouteTestSupport.makeCommandUpdate(text: "/ping", updateId: 710)])

        let handled = await sink.handledRecords.waitForCount(1, retries: 100)
        #expect(handled.count == 1)
        let record = try #require(handled.first)
        #expect(record.routeKind == .command)
        #expect(record.routeName == "ping")
        #expect(record.duration >= .milliseconds(5))
    }

    @Test func handledEventCarriesDuration() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.timing"))
        let recorder = TelerouteTestRecorder<TelerouteEvent>()

        let eventTask = Task {
            for await event in router.eventStream() {
                await recorder.record(event)
                if event.kind == .handled { break }
            }
        }

        router.command("work") { _ in
            try? await Task.sleep(for: .milliseconds(10))
        }

        await router.handle()
        await router.process([TelerouteTestSupport.makeCommandUpdate(text: "/work", updateId: 711)])
        let events = await recorder.waitForCount(2, retries: 100)
        eventTask.cancel()
        try? await Task.sleep(for: .milliseconds(20))

        let handled = events.last { $0.kind == .handled }
        #expect(handled != nil)
        #expect(handled?.duration ?? .zero >= .milliseconds(5))
    }

    @Test func routeScopesRegisterCommandsAndGroups() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let router = TelerouteRuntime(bot: bot, logger: .init(label: "router.dsl"))
        let recorder = TelerouteTestRecorder<String>()

        router.command("start", description: "Begin") { _ in
            await recorder.record("start")
        }
        router.group(
            "admin",
            guards: [TeleroutePrivateChatGuard()]
        ) { admin in
            admin.command("ban") { _ in
                await recorder.record("admin_ban")
            }
        }

        await router.handle()
        await router.process([TelerouteTestSupport.makeCommandUpdate(text: "/start", chatId: 100, updateId: 720)])
        await router.process([TelerouteTestSupport.makeCommandUpdate(text: "/admin_ban", chatType: .private, chatId: 101, updateId: 721)])
        await router.process([TelerouteTestSupport.makeCommandUpdate(text: "/admin_ban", chatType: .group, chatId: 102, updateId: 722)])

        let values = await recorder.waitForCount(2, retries: 100)
        #expect(values.contains("start"))
        #expect(values.contains("admin_ban"))
    }
}

private actor RecordingMetricsSink: TelerouteMetricsSink {
    struct HandledRecord: Sendable {
        let routeKind: TelerouteEvent.RouteKind
        let routeName: String?
        let duration: Duration
    }

    let handledRecords = TelerouteTestRecorder<HandledRecord>()

    func recordHandled(
        routeKind: TelerouteEvent.RouteKind,
        routeName: String?,
        chatId: Int64?,
        userId: Int64?,
        duration: Duration
    ) async {
        await handledRecords.record(.init(routeKind: routeKind, routeName: routeName, duration: duration))
    }
}

// MARK: - Fixtures

private struct ItemCallback: TelerouteCallback {
    static let path = "item/{id}"

    let id: String

    init(id: String) {
        self.id = id
    }

    init(parameters: TelerouteParameters) throws {
        self.id = try parameters.require("id")
    }

    var parameters: [String: String] {
        ["id": self.id]
    }
}

private struct PageCallback: TelerouteCallback {
    static let path = "list/{page}"

    let page: Int

    init(page: Int) {
        self.page = page
    }

    init(parameters: TelerouteParameters) throws {
        let page = try parameters.require("page")
        guard let page = Int(page) else {
            throw TelerouteError.missingParameter("page")
        }
        self.page = page
    }

    var parameters: [String: String] {
        ["page": String(self.page)]
    }
}

private struct ConfirmTypedCallback: TelerouteCallback {
    static let path = "typed_confirm/{decision}"

    let decision: String

    init(decision: String) {
        self.decision = decision
    }

    init(parameters: TelerouteParameters) throws {
        self.decision = try parameters.require("decision")
    }

    var parameters: [String: String] {
        ["decision": self.decision]
    }
}

private struct TypedCallbackFlow: TelerouteFlow {
    enum Step: String, Sendable {
        case waiting
    }

    static let recorder = TelerouteTestRecorder<String>()

    func boot(flow: TelerouteFlowGroup<TypedCallbackFlow>) {
        let confirmation = flow.callback(ConfirmTypedCallback.self, at: .waiting) { callback, _ in
            await Self.recorder.record("confirmed:\(callback.decision)")
        }

        flow.start("typed_flow", at: .waiting) { _ in
            let button = try flow.render(
                confirmation.button(ConfirmTypedCallback(decision: "yes"), "Confirm")
            )
            await Self.recorder.record("started:\(button.callbackData ?? "")")
        }
    }
}
