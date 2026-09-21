import Foundation
import Testing
import Teleroute
import TelerouteMacros
import TelerouteTestSupport

/// Tests for keyboards built from inside a handler, the deferred keyboard
/// builders on `Reply`/`Send`/`Edit`, the `callback_data` length guard, and
/// the ready-made button patterns.
@Suite struct TelerouteKeyboardSugarTests {

    // MARK: - Keyboards from the context

    @Test func contextKeyboardRendersButtonsForRoutesInNestedGroups() async throws {
        let router = Teleroute()
        let route = router.group("admin").callback(KeyboardOpenCallback.self) { _, _ in "opened" }
        let recorder = TelerouteTestRecorder<String>()

        router.command("menu") { (context: TelerouteContext) -> Void in
            let markup = try context.keyboard {
                Row { route.button(KeyboardOpenCallback(id: "7"), "Open") }
            }
            await recorder.record(markup.inlineKeyboard[0][0].callbackData ?? "nil")
        }

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.sendCommand("menu")
        }

        #expect(await recorder.waitForCount(1) == ["admin/open/7"])
        await bot.shutdown()
    }

    @Test func contextKeyboardRejectsUnregisteredCallbackRoutes() async throws {
        let router = Teleroute()
        let recorder = TelerouteTestRecorder<String>()

        router.command("menu") { (context: TelerouteContext) -> Void in
            do {
                _ = try context.keyboard {
                    Row { KeyboardUnregisteredCallback(id: "1").button("Nope") }
                }
                await recorder.record("rendered")
            } catch let error as TelerouteError {
                await recorder.record(String(describing: error))
            }
        }

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.sendCommand("menu")
        }

        let recorded = await recorder.waitForCount(1)
        #expect(recorded.first?.contains("callbackRouteNotRegistered") == true)
        await bot.shutdown()
    }

    @Test func contextKeyboardThrowsWhenBuiltOutsideARunningRouter() throws {
        let context = TelerouteContext(
            bot: try TelerouteTestSupport.makeClient(),
            update: TelerouteTestSupport.makeCommandUpdate(text: "/menu")
        )

        do {
            _ = try context.keyboard {
                Row { TelerouteButton.url("Docs", "https://example.com") }
            }
            Issue.record("Expected keyboardScopeMissing")
        } catch let error as TelerouteError {
            guard case .keyboardScopeMissing = error else {
                Issue.record("Unexpected error \(error)")
                return
            }
        }
    }

    @Test func flowStepsCanBuildKeyboardsFromTheirContext() async throws {
        let router = Teleroute()
        let recorder = TelerouteTestRecorder<String>()
        router.flow(KeyboardProbeFlow(recorder: recorder))

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.sendCommand("probe")
            _ = await client.sendMessage("Alice", updateId: 2)
        }

        // The context and the flow group agree on route-handle buttons: the
        // handle carries its full pattern, so the scope used to render it
        // does not change the result.
        #expect(await recorder.waitForCount(2) == ["open/Alice", "open/Alice"])
        await bot.shutdown()
    }

    @Test func flowContextResolvesBareCallbackButtonsFromAPrefixedScope() async throws {
        // A flow mounted inside a group registers its callbacks under that
        // group's prefix. The flow context renders against the router root,
        // which does not know the prefix — but resolution searches every
        // registered route, so both paths agree.
        let router = Teleroute()
        let recorder = TelerouteTestRecorder<String>()
        router.group("admin").flow(KeyboardPrefixedProbeFlow(recorder: recorder))

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.sendCommand("admin_probe")
            _ = await client.sendMessage("Alice", updateId: 2)
        }

        #expect(
            await recorder.waitForCount(2) == ["admin/open/Alice", "admin/open/Alice"]
        )
        await bot.shutdown()
    }

    // MARK: - Resolving callbacks registered in groups

    @Test func bareCallbackResolvesToTheGroupThatRegisteredIt() throws {
        let router = Teleroute()
        router.group("admin").callback(KeyboardOpenCallback.self) { _, _ in "opened" }

        // Rendered from the root, which never saw the "admin" prefix.
        #expect(
            try router.render(KeyboardOpenCallback(id: "7").button("Open")).callbackData
                == "admin/open/7"
        )
    }

    @Test func bareCallbackResolvesThroughNestedGroups() throws {
        let router = Teleroute()
        router.group("a").group("b").callback(KeyboardOpenCallback.self) { _, _ in "opened" }

        #expect(
            try router.render(KeyboardOpenCallback(id: "7").button("Open")).callbackData
                == "a/b/open/7"
        )
    }

    @Test func scopeThatRegisteredTheRouteWinsOverTheSearch() throws {
        let router = Teleroute()
        let group = router.group("admin")
        router.callback(KeyboardOpenCallback.self) { _, _ in "root" }
        group.callback(KeyboardOpenCallback.self) { _, _ in "admin" }

        // Each scope keeps rendering its own route; only a scope without one
        // falls back to the search.
        let button = KeyboardOpenCallback(id: "7").button("Open")
        #expect(try router.render(button).callbackData == "open/7")
        #expect(try group.render(button).callbackData == "admin/open/7")
    }

    @Test func callbackRegisteredInTwoGroupsIsReportedAsAmbiguous() throws {
        let router = Teleroute()
        router.group("admin").callback(KeyboardOpenCallback.self) { _, _ in "a" }
        router.group("staff").callback(KeyboardOpenCallback.self) { _, _ in "s" }

        do {
            _ = try router.render(KeyboardOpenCallback(id: "7").button("Open"))
            Issue.record("Expected ambiguousCallbackRoute")
        } catch let TelerouteError.ambiguousCallbackRoute(path, matches) {
            #expect(path == "open/{id}")
            #expect(matches == ["admin/open/{id}", "staff/open/{id}"])
        }
    }

    @Test func unregisteredCallbackStillReportsNotRegistered() throws {
        let router = Teleroute()
        router.callback(KeyboardOpenCallback.self) { _, _ in "opened" }

        do {
            _ = try router.render(KeyboardUnregisteredCallback(id: "1").button("Nope"))
            Issue.record("Expected callbackRouteNotRegistered")
        } catch let TelerouteError.callbackRouteNotRegistered(path) {
            #expect(path == "never-registered/{id}")
        }
    }

    @Test func suffixMatchingDoesNotConfusePartialPathSegments() throws {
        let router = Teleroute()
        // "reopen/{id}" ends with the characters of "open/{id}" but is a
        // different route: matching is per segment, not per character.
        router.callback(KeyboardReopenCallback.self) { _, _ in "reopened" }

        do {
            _ = try router.render(KeyboardOpenCallback(id: "7").button("Open"))
            Issue.record("Expected callbackRouteNotRegistered")
        } catch let TelerouteError.callbackRouteNotRegistered(path) {
            #expect(path == "open/{id}")
        }
    }

    // MARK: - Initializers and modifiers

    @Test func initializerFormMatchesTheRouteHandleAndValueForms() throws {
        let router = Teleroute()
        let route = router.callback(KeyboardOpenCallback.self) { _, _ in "opened" }

        let fromInit = try router.render(TelerouteButton("Open") { KeyboardOpenCallback(id: "7") })
        let fromHandle = try router.render(route.button(KeyboardOpenCallback(id: "7"), "Open"))
        let fromValue = try router.render(KeyboardOpenCallback(id: "7").button("Open"))

        #expect(fromInit.callbackData == "open/7")
        #expect(fromInit.callbackData == fromHandle.callbackData)
        #expect(fromInit.callbackData == fromValue.callbackData)
        #expect(fromInit.text == "Open")
    }

    @Test func initializersCoverEveryButtonKind() throws {
        let router = Teleroute()

        func render(_ button: TelerouteButton) throws -> InlineKeyboardButton {
            try router.render(button)
        }

        #expect(try render(TelerouteButton("Docs", url: "https://example.com")).url
            == "https://example.com")
        #expect(try render(TelerouteButton("App", webApp: "https://example.com/app")).webApp?.url
            == "https://example.com/app")
        #expect(try render(TelerouteButton("Copy", copy: "PROMO")).copyText?.text == "PROMO")
        #expect(try render(TelerouteButton("Share", switchInlineQuery: "cats")).switchInlineQuery
            == "cats")
        #expect(
            try render(TelerouteButton("Here", switchInlineQuery: "cats", currentChat: true))
                .switchInlineQueryCurrentChat == "cats"
        )
        #expect(try render(TelerouteButton("3 / 10", .disabled)).disabled != nil)
        #expect(try render(TelerouteButton("Pay", .pay)).pay == true)
        #expect(try render(TelerouteButton("Play", .callbackGame)).callbackGame != nil)
    }

    @Test func modifiersApplyToBothCallbackAndRawButtons() throws {
        let router = Teleroute()
        router.callback(KeyboardOpenCallback.self) { _, _ in "opened" }

        let callbackButton = try router.render(
            TelerouteButton("Delete") { KeyboardOpenCallback(id: "7") }
                .style(.danger)
                .icon("123")
        )
        #expect(callbackButton.style == .danger)
        #expect(callbackButton.iconCustomEmojiId == "123")
        #expect(callbackButton.callbackData == "open/7")

        // A raw-destination button used to drop its chained style entirely.
        let rawButton = try router.render(
            TelerouteButton("Docs", url: "https://example.com").style(.primary)
        )
        #expect(rawButton.style == .primary)
        #expect(rawButton.url == "https://example.com")
        #expect(rawButton.text == "Docs")

        // Chaining onto a static factory works the same way.
        let fromFactory = try router.render(
            TelerouteButton.url("Docs", "https://example.com").icon("456")
        )
        #expect(fromFactory.iconCustomEmojiId == "456")
        #expect(fromFactory.url == "https://example.com")
    }

    @Test func initializerFormComposesInsideBuilders() throws {
        let router = Teleroute()
        router.callback(KeyboardOpenCallback.self) { _, _ in "opened" }

        // Note: the leading-dot form (`.init("Docs", url: …)`) does NOT work
        // as a builder expression — Swift parses it as a member of the
        // preceding line. The type name is required.
        let markup = try router.keyboard {
            Row {
                TelerouteButton("Open") { KeyboardOpenCallback(id: "1") }
                TelerouteButton("Docs", url: "https://example.com")
            }
            TelerouteButton("3 / 10", .disabled)               // bare expression
        }

        #expect(markup.inlineKeyboard.map(\.count) == [2, 1])
        #expect(markup.inlineKeyboard[0][0].callbackData == "open/1")
        #expect(markup.inlineKeyboard[0][1].url == "https://example.com")
        #expect(markup.inlineKeyboard[1][0].disabled != nil)
    }

    @Test func flowStepsReachTheFullHelperSurfaceThroughTheCoreContext() async throws {
        // TelerouteFlowContext is not a TelerouteRequestContext: it forwards
        // the common helpers and exposes `context` for everything else. This
        // is the escape hatch the documentation points at, so it has to
        // compile and reach Telegram.
        let router = Teleroute()
        router.flow(KeyboardHelperProbeFlow())

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.sendCommand("helpers")
            _ = await client.sendMessage("go", updateId: 2)
        }

        let texts = telegram.effects.compactMap { effect -> String? in
            guard case let .sentMessage(message) = effect else { return nil }
            return message.text
        }
        #expect(texts.contains("forwarded"))
        await bot.shutdown()
    }

    // MARK: - Deferred builders on responses

    @Test func replyKeyboardBuilderReachesTelegramAsInlineMarkup() async throws {
        let router = Teleroute()
        let route = router.callback(KeyboardOpenCallback.self) { _, _ in "opened" }

        router.command("menu") { _ in
            Reply("Pick one:").keyboard {
                Row {
                    route.button(KeyboardOpenCallback(id: "7"), "Open")
                    TelerouteButton.url("Docs", "https://example.com")
                }
            }
        }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            let result = await client.sendCommand("menu")
            #expect(result.terminalEvent?.kind == .handled)
        }

        guard case let .sentMessage(message) = telegram.effects.first else {
            Issue.record("Expected a sent message, got \(telegram.effects)")
            return
        }
        #expect(message.text == "Pick one:")
        guard case let .InlineKeyboardMarkup(markup) = message.replyMarkup else {
            Issue.record("Expected inline markup, got \(String(describing: message.replyMarkup))")
            return
        }
        #expect(markup.inlineKeyboard[0][0].callbackData == "open/7")
        #expect(markup.inlineKeyboard[0][1].url == "https://example.com")
        await bot.shutdown()
    }

    @Test func editKeyboardBuilderReachesTelegram() async throws {
        let router = Teleroute()
        // The handler needs a button for its own route, so it uses the
        // value-side `button(_:)` rather than the route handle it is defining.
        router.callback(KeyboardOpenCallback.self) { callback, _ in
            Edit("Opened \(callback.id)").keyboard {
                Row { KeyboardOpenCallback(id: callback.id).button("Again") }
            }
        }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.execute(
                TelerouteTestSupport.makeCallbackUpdate(data: "open/7")
            )
        }

        let edits = telegram.effects.compactMap { effect -> TelerouteRecordedEdit? in
            guard case let .editedMessage(edit) = effect else { return nil }
            return edit
        }
        #expect(edits.first?.text == "Opened 7")
        #expect(edits.first?.replyMarkup?.inlineKeyboard[0][0].callbackData == "open/7")
        await bot.shutdown()
    }

    @Test func deferredBuilderFailureIsRenderedByTheErrorRenderer() async throws {
        let router = Teleroute()
        router.command("menu") { _ in
            Reply("Pick one:").keyboard {
                Row { KeyboardUnregisteredCallback(id: "1").button("Nope") }
            }
        }

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(
                replayProtectionStorage: nil,
                errorRenderer: { error, _ in
                    .reply("failed: \(error is TelerouteError)")
                }
            )
        )
        try await bot.test { client in
            _ = await client.sendCommand("menu")
        }

        guard case let .sentMessage(message) = telegram.effects.first else {
            Issue.record("Expected a rendered error, got \(telegram.effects)")
            return
        }
        #expect(message.text == "failed: true")
        await bot.shutdown()
    }

    @Test func replyCanRemoveTheKeyboardAndForceAReply() {
        guard case .ReplyKeyboardRemove = Reply("bye").removeKeyboard().replyMarkup else {
            Issue.record("Expected a keyboard removal")
            return
        }
        guard case let .ForceReply(force) = Reply("name?").forceReply(placeholder: "Name").replyMarkup else {
            Issue.record("Expected a forced reply")
            return
        }
        #expect(force.inputFieldPlaceholder == "Name")
    }

    // MARK: - The 64-byte callback_data guard

    @Test func callbackDataLongerThanSixtyFourBytesIsRejectedAtRenderTime() throws {
        let router = Teleroute()
        let route = router.callback(KeyboardOpenCallback.self) { _, _ in "opened" }

        #expect(throws: TelerouteError.self) {
            _ = try route.callbackData(for: .init(id: String(repeating: "a", count: 64)))
        }
        // Just inside the limit: "open/" is 5 bytes, leaving 59.
        #expect(
            try route.callbackData(for: .init(id: String(repeating: "a", count: 59)))
                .utf8.count == 64
        )
    }

    @Test func percentEncodingIsCountedAgainstTheLimit() throws {
        let router = Teleroute()
        let route = router.callback(KeyboardOpenCallback.self) { _, _ in "opened" }

        // 20 Cyrillic characters fit in 64 characters but not in 64 bytes:
        // each becomes a 6-byte "%D0%BF" percent-encoded pair.
        let cyrillic = String(repeating: "п", count: 20)
        #expect(cyrillic.count < 64)

        do {
            _ = try route.callbackData(for: .init(id: cyrillic))
            Issue.record("Expected callbackDataTooLong")
        } catch let TelerouteError.callbackDataTooLong(_, bytes) {
            #expect(bytes > 64)
        }
    }

    @Test func buttonRenderingSurfacesTheLengthError() throws {
        let router = Teleroute()
        let route = router.callback(KeyboardOpenCallback.self) { _, _ in "opened" }

        #expect(throws: TelerouteError.self) {
            _ = try router.keyboard {
                Row { route.button(.init(id: String(repeating: "x", count: 100)), "Too long") }
            }
        }
    }

    // MARK: - Patterns

    @Test func gridSplitsButtonsIntoRowsAndComposesInsideTheBuilder() throws {
        let router = Teleroute()
        let route = router.callback(KeyboardOpenCallback.self) { _, _ in "opened" }

        let buttons = (1...7).map { route.button(.init(id: "\($0)"), "#\($0)") }
        #expect(buttons.grid(columns: 3).map(\.count) == [3, 3, 1])
        #expect(buttons.grid(columns: 0).map(\.count) == Array(repeating: 1, count: 7))

        let markup = try router.keyboard {
            buttons.grid(columns: 3)
            Row { TelerouteButton.url("Docs", "https://example.com") }
        }
        #expect(markup.inlineKeyboard.map(\.count) == [3, 3, 1, 1])
    }

    @Test func pageStripWindowsAroundTheCurrentPage() throws {
        let router = Teleroute()
        let route = router.callback(KeyboardPageCallback.self) { _, _ in "paged" }

        let strip = TeleroutePagination.pageStrip(route, page: 9, pageCount: 20, window: 2) {
            KeyboardPageCallback(page: $0)
        }
        let labels = try strip.map { try router.render($0).text }
        #expect(labels == ["1", "…", "8", "9", "· 10 ·", "11", "12", "…", "20"])

        // The current page is not clickable; the others are.
        let rendered = try strip.map { try router.render($0) }
        #expect(rendered.filter { $0.callbackData != nil }.count == labels.count - 3)
    }

    @Test func pageStripIsEmptyForASinglePage() throws {
        let router = Teleroute()
        let route = router.callback(KeyboardPageCallback.self) { _, _ in "paged" }

        #expect(
            TeleroutePagination.pageStrip(route, page: 0, pageCount: 1) {
                KeyboardPageCallback(page: $0)
            }.isEmpty
        )
    }

    @Test func navigationRowWithCounterKeepsAStableWidth() throws {
        let router = Teleroute()
        let route = router.callback(KeyboardPageCallback.self) { _, _ in "paged" }

        func labels(page: Int) throws -> [String] {
            try TeleroutePagination.navigationRow(
                route,
                page: page,
                pageCount: 3,
                counter: true
            ) { KeyboardPageCallback(page: $0) }
                .map { try router.render($0).text }
        }

        #expect(try labels(page: 0) == ["·", "1 / 3", "▶︎"])
        #expect(try labels(page: 1) == ["◀︎", "2 / 3", "▶︎"])
        #expect(try labels(page: 2) == ["◀︎", "3 / 3", "·"])
    }

    @Test func confirmRowBuildsStyledYesNoButtons() throws {
        let router = Teleroute()
        let route = router.callback(KeyboardConfirmCallback.self) { _, _ in "confirmed" }

        let row = TelerouteConfirm.row(
            route,
            confirm: .init(id: "7", yes: "1"),
            cancel: .init(id: "7", yes: "0")
        )
        let rendered = try row.map { try router.render($0) }
        #expect(rendered.map(\.text) == ["✅ Yes", "❌ No"])
        #expect(rendered.map(\.style) == [.success, .danger])
        #expect(rendered.map(\.callbackData) == ["confirm/7/1", "confirm/7/0"])
    }

    // MARK: - Reply keyboards

    @Test func replyKeyboardRowAcceptsLoops() {
        let markup = ReplyKeyboardMarkup(resize: true) {
            KeyRow {
                for label in ["A", "B", "C"] {
                    KeyButton(label)
                }
            }
            KeyRow { "Cancel" }
        }
        #expect(markup.keyboard.map(\.count) == [3, 1])
        #expect(markup.keyboard[0].map(\.text) == ["A", "B", "C"])
    }

    @Test func keyButtonExposesTheFullRequestSurface() {
        let markup = ReplyKeyboardMarkup {
            KeyRow {
                KeyButton("Users").requestUsers(id: 1, maxQuantity: 3)
                KeyButton("Channel").requestChat(id: 2, isChannel: true)
            }
            KeyRow {
                KeyButton("Quiz").requestPoll("quiz")
                KeyButton("App").webApp(url: "https://example.com/app")
                KeyButton("Styled").style(.primary)
            }
        }

        #expect(markup.keyboard[0][0].requestUsers?.maxQuantity == 3)
        #expect(markup.keyboard[0][1].requestChat?.chatIsChannel == true)
        #expect(markup.keyboard[1][0].requestPoll?.type == "quiz")
        #expect(markup.keyboard[1][1].webApp?.url == "https://example.com/app")
        #expect(markup.keyboard[1][2].style == .primary)
    }
}

// MARK: - Fixtures

@TelerouteCallback("open/{id}")
private struct KeyboardOpenCallback {
    let id: String
}

@TelerouteCallback("page/{page}")
private struct KeyboardPageCallback {
    let page: Int
}

@TelerouteCallback("confirm/{id}/{yes}")
private struct KeyboardConfirmCallback {
    let id: String
    let yes: String
}

/// Flow whose step uses helpers that live on the core context rather than on
/// the flow context itself.
private struct KeyboardHelperProbeFlow: TelerouteFlow {
    enum Step: String { case go }

    func boot(flow: TelerouteFlowGroup<KeyboardHelperProbeFlow>) {
        flow.start("helpers", at: .go) { context in
            try await context.reply("Send anything.")       // on the flow context
        }
        flow.message(at: .go) { context in
            // Not forwarded by the flow context — reached through `context`.
            try await context.context.send("forwarded")
            #expect(context.context.chatId != nil)
            try await context.finish()
        }
    }
}

/// Flow mounted inside a group, so its callback scope carries a prefix.
private struct KeyboardPrefixedProbeFlow: TelerouteFlow {
    enum Step: String { case name }

    let recorder: TelerouteTestRecorder<String>

    func boot(flow: TelerouteFlowGroup<KeyboardPrefixedProbeFlow>) {
        flow.callback(KeyboardOpenCallback.self, at: .name) { _, _ in }

        flow.start("probe", at: .name) { context in
            try await context.reply("Send your name.")
        }
        flow.message(at: .name) { context in
            let button = KeyboardOpenCallback(id: context.message?.text ?? "?")
                .button("Open")
            await self.recorder.record(
                (try? flow.keyboard([[button]]).inlineKeyboard[0][0].callbackData) ?? "nil"
            )
            await self.recorder.record(
                (try? context.keyboard { Row { button } }
                    .inlineKeyboard[0][0].callbackData) ?? "nil"
            )
            try await context.finish()
        }
    }
}

/// Flow whose message step renders a keyboard through the flow context,
/// proving the route scope reaches contexts built by the flow coordinator.
private struct KeyboardProbeFlow: TelerouteFlow {
    enum Step: String { case name }

    let recorder: TelerouteTestRecorder<String>

    func boot(flow: TelerouteFlowGroup<KeyboardProbeFlow>) {
        let open = flow.callback(KeyboardOpenCallback.self, at: .name) { _, _ in }

        flow.start("probe", at: .name) { context in
            try await context.reply("Send your name.")
        }
        flow.message(at: .name) { context in
            let button = open.button(
                KeyboardOpenCallback(id: context.message?.text ?? "?"),
                "Open"
            )
            let fromContext = try context.keyboard { Row { button } }
            let fromGroup = try flow.keyboard([[button]])
            await self.recorder.record(fromContext.inlineKeyboard[0][0].callbackData ?? "nil")
            await self.recorder.record(fromGroup.inlineKeyboard[0][0].callbackData ?? "nil")
            try await context.finish()
        }
    }
}

@TelerouteCallback("reopen/{id}")
private struct KeyboardReopenCallback {
    let id: String
}

@TelerouteCallback("never-registered/{id}")
private struct KeyboardUnregisteredCallback {
    let id: String
}
