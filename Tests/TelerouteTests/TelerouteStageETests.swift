import Testing
@testable import Teleroute
import TelerouteTestSupport
import SwiftTelegramBot

@Suite(.serialized)
struct TelerouteStageETests {
    @Test func keyboardBuilderGroupsButtonsIntoRows() throws {
        let keyboard = try TelerouteKeyboardBuilder.build {
            TelerouteKeyboardBuilder.Row {
                TGInlineKeyboardButton(text: "A", callbackData: "a")
                TGInlineKeyboardButton(text: "B", callbackData: "b")
            }
            TelerouteKeyboardBuilder.Row {
                TGInlineKeyboardButton(text: "C", callbackData: "c")
            }
        }

        #expect(keyboard.inlineKeyboard.count == 2)
        #expect(keyboard.inlineKeyboard[0].map(\.text) == ["A", "B"])
        #expect(keyboard.inlineKeyboard[1].map(\.text) == ["C"])
    }

    @Test func keyboardBuilderFlattensTopLevelButtonsIntoOneRow() throws {
        let keyboard = try TelerouteKeyboardBuilder.build {
            TGInlineKeyboardButton(text: "X", callbackData: "x")
            TGInlineKeyboardButton(text: "Y", callbackData: "y")
        }

        #expect(keyboard.inlineKeyboard.count == 1)
        #expect(keyboard.inlineKeyboard[0].map(\.text) == ["X", "Y"])
    }

    @Test func keyboardBuilderSupportsConditionalRows() throws {
        let includeExtra = true
        let keyboard = try TelerouteKeyboardBuilder.build {
            TelerouteKeyboardBuilder.Row {
                TGInlineKeyboardButton(text: "Main", callbackData: "main")
            }
            if includeExtra {
                TelerouteKeyboardBuilder.Row {
                    TGInlineKeyboardButton(text: "Extra", callbackData: "extra")
                }
            }
        }

        #expect(keyboard.inlineKeyboard.count == 2)
        #expect(keyboard.inlineKeyboard[1].first?.text == "Extra")
    }

    @Test func paginationNavigationRowHidesPrevOnFirstPage() throws {
        let buttons = TeleroutePagination.navigationRow(
            path: "list",
            page: 0,
            pageCount: 3
        ) { text, path, params in
            TGInlineKeyboardButton(text: text, callbackData: "\(path)/\(params["page"] ?? "")")
        }

        #expect(buttons.count == 1)
        #expect(buttons.first?.text == "Next ▶︎")
    }

    @Test func paginationNavigationRowHidesNextOnLastPage() throws {
        let buttons = TeleroutePagination.navigationRow(
            path: "list",
            page: 2,
            pageCount: 3
        ) { text, _, params in
            TGInlineKeyboardButton(text: text, callbackData: params["page"] ?? "")
        }

        #expect(buttons.count == 1)
        #expect(buttons.first?.text == "◀︎ Prev")
    }

    @Test func flowTypedCallbackRoutesAndBuildsButton() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let router = Teleroute(bot: bot, logger: .init(label: "router.flow.typed-callback"))

        router.add(flow: TypedCallbackFlow())

        await router.handle()
        await router.process([TelerouteTestSupport.makeCommandUpdate(text: "/typed_flow", updateId: 700)])
        _ = await TypedCallbackFlow.recorder.waitForCount(1, retries: 100)

        // Button built with the typed flow API must produce callback data that
        // the registered typed callback route matches.
        let buttonData = try router.rootGroup.callbackData(
            for: ConfirmTypedCallback(decision: "yes")
        )
        await router.process([
            TelerouteTestSupport.makeCallbackUpdate(data: buttonData, updateId: 701),
        ])
        let confirmed = await TypedCallbackFlow.recorder.waitForCount(2, retries: 100)
        #expect(confirmed.contains("confirmed:yes"))
    }

    @Test func metricsSinkReceivesHandledEventWithDuration() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let sink = RecordingMetricsSink()
        let router = Teleroute(
            bot: bot,
            logger: .init(label: "router.metrics"),
            metricsSink: sink
        )

        router.command("ping") { _, _ in
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
        let router = Teleroute(bot: bot, logger: .init(label: "router.timing"))
        let recorder = TelerouteTestRecorder<TelerouteEvent>()

        let eventTask = Task {
            for await event in router.events {
                await recorder.record(event)
                if event.kind == .handled { break }
            }
        }

        router.command("work") { _, _ in
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

    @Test func routeBuilderDslRegistersCommandsAndGroups() async throws {
        let bot = try await TelerouteTestSupport.makeBot()
        let router = Teleroute(bot: bot, logger: .init(label: "router.dsl"))
        let recorder = TelerouteTestRecorder<String>()

        router.routes {
            TelerouteRouteCommand("start", description: "Begin") { _, _ in
                await recorder.record("start")
            }
            TelerouteRouteGroup("admin", routeGuards: [TeleroutePrivateChatGuard()]) {
                TelerouteRouteCommand("ban") { _, _ in
                    await recorder.record("admin_ban")
                }
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
        get throws { ["decision": self.decision] }
    }

    func handle(update: TGUpdate, context: TelerouteContext) async throws {
        await TypedCallbackFlow.recorder.record("confirmed:\(self.decision)")
    }
}

private struct TypedCallbackFlow: TelerouteFlow {
    enum Step: String, Sendable {
        case waiting
    }

    static let recorder = TelerouteTestRecorder<String>()

    func boot(flow: TelerouteFlowGroup<TypedCallbackFlow>) {
        flow.start("typed_flow", at: .waiting) { _, _ in
            await Self.recorder.record("started")
        }

        flow.callback(ConfirmTypedCallback.self, at: .waiting) { _, _, callback in
            await Self.recorder.record("confirmed:\(callback.decision)")
        }
    }
}
