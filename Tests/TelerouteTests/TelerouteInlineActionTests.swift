import Foundation
import HTTPTypes
import Synchronization
import Testing
import TelerouteMacros
import TelerouteTestSupport
@_spi(Testing) @testable import Teleroute

/// Tests for buttons that carry their handler inline.
@Suite struct TelerouteInlineActionTests {

    // MARK: - Pressing

    @Test func pressingRunsTheHandlerAndSendsItsResponse() async throws {
        let pressed = TelerouteTestRecorder<String>()
        let router = Teleroute()
        router.command("menu") { _ in
            Reply("Order 7").keyboard {
                Row {
                    TelerouteButton("Approve") { context in
                        await pressed.record("approve:\(context.userId ?? -1)")
                        return Edit("Order 7 approved")
                    }
                    TelerouteButton("Cancel") { Edit("Cancelled") }
                }
            }
        }

        let (bot, telegram) = try Self.makeBot(router: router)
        let data = try await Self.renderKeyboard(bot: bot, telegram: telegram)
        #expect(data.count == 2)

        try await bot.test { client in
            _ = await client.execute(TelerouteTestSupport.makeCallbackUpdate(data: data[0]))
        }
        #expect(await pressed.waitForCount(1) == ["approve:1"])
        #expect(Self.edits(telegram).last == "Order 7 approved")

        // The parameterless form works the same way.
        try await bot.test { client in
            _ = await client.execute(
                TelerouteTestSupport.makeCallbackUpdate(data: data[1], updateId: 4)
            )
        }
        #expect(Self.edits(telegram).last == "Cancelled")
        await bot.shutdown()
    }

    @Test func handlerReceivesTheCallbackQueryOfThePress() async throws {
        let seen = TelerouteTestRecorder<String>()
        let router = Teleroute()
        router.command("menu") { outer in
            Reply("Menu").keyboard {
                Row {
                    TelerouteButton("Go") { press in
                        // The press carries its own callback query...
                        await seen.record("id:\(press.callbackQuery?.id ?? "nil")")
                        await seen.record("data:\(press.callbackData ?? "nil")")
                        await seen.record("from:\(press.callbackQuery?.from.id ?? -1)")
                        // ...so answering through it works, unlike the
                        // captured context of the update that rendered it.
                        await seen.record("outer:\(outer.callbackQuery?.id ?? "nil")")
                        try await press.answerCallbackQuery("Done")
                        return TelerouteResponse.none
                    }
                }
            }
        }

        let (bot, telegram) = try Self.makeBot(router: router)
        let data = try await Self.renderKeyboard(bot: bot, telegram: telegram)
        telegram.reset()

        try await bot.test { client in
            // Same user the keyboard was rendered for; a different one would
            // be turned away by the default `.user` scope.
            _ = await client.execute(TelerouteTestSupport.makeCallbackUpdate(data: data[0]))
        }

        #expect(await seen.waitForCount(4) == [
            "id:callback-id",
            "data:\(data[0])",
            "from:1",
            "outer:nil",
        ])
        #expect(Self.answers(telegram) == ["Done"])
        await bot.shutdown()
    }

    @Test func editTargetsTheMessageTheButtonIsAttachedTo() async throws {
        let router = Teleroute()
        router.command("menu") { _ in
            Reply("Before").keyboard {
                Row {
                    TelerouteButton("Replace text") { _ in
                        Edit("After")
                    }
                    TelerouteButton("Replace text and buttons") { _ in
                        Edit("Rebuilt").keyboard {
                            Row { TelerouteButton("Closed", .disabled) }
                        }
                    }
                }
            }
        }

        let (bot, telegram) = try Self.makeBot(router: router)
        // Rendered and pressed in the same chat, so the default `.user` scope
        // lets the press through.
        let data = try await Self.renderKeyboard(bot: bot, telegram: telegram, chatId: 555)
        telegram.reset()

        try await bot.test { client in
            _ = await client.execute(TelerouteTestSupport.makeCallbackUpdate(
                data: data[0],
                chatId: 555
            ))
        }

        // The synthetic callback hosts the keyboard on message 1 of that chat;
        // `Edit` with no explicit target resolves to exactly that message.
        let edit = try #require(Self.edit(telegram))
        #expect(edit.text == "After")
        #expect(edit.messageId == 1)
        #expect(edit.chatId?.int64Value == 555)

        telegram.reset()
        try await bot.test { client in
            _ = await client.execute(TelerouteTestSupport.makeCallbackUpdate(
                data: data[1],
                chatId: 555,
                updateId: 4
            ))
        }

        let rebuilt = try #require(Self.edit(telegram))
        #expect(rebuilt.text == "Rebuilt")
        #expect(rebuilt.messageId == 1)
        #expect(rebuilt.replyMarkup?.inlineKeyboard[0][0].text == "Closed")
        await bot.shutdown()
    }

    @Test func handlerStaysPressableWithinItsTTL() async throws {
        let pressed = TelerouteTestRecorder<Int>()
        let counter = Mutex(0)
        let router = Teleroute()
        router.command("menu") { _ in
            Reply("Counter").keyboard {
                Row {
                    TelerouteButton("+1") { _ in
                        let value = counter.withLock { $0 += 1; return $0 }
                        await pressed.record(value)
                        return Edit("Count: \(value)")
                    }
                }
            }
        }

        let (bot, telegram) = try Self.makeBot(router: router)
        let data = try await Self.renderKeyboard(bot: bot, telegram: telegram)

        try await bot.test { client in
            _ = await client.execute(TelerouteTestSupport.makeCallbackUpdate(data: data[0]))
            _ = await client.execute(
                TelerouteTestSupport.makeCallbackUpdate(data: data[0], updateId: 4)
            )
        }

        #expect(await pressed.waitForCount(2) == [1, 2])
        await bot.shutdown()
    }

    @Test func unknownIdentifierGetsTheConfiguredExpiredResponse() async throws {
        let router = Teleroute()
        router.command("menu") { _ in "hi" }

        let (bot, telegram) = try Self.makeBot(
            router: router,
            expired: .answerCallback("Button expired")
        )
        try await bot.test { client in
            _ = await client.execute(
                TelerouteTestSupport.makeCallbackUpdate(data: "_ta/nosuchbutton")
            )
        }

        let answers = telegram.effects.compactMap { effect -> String? in
            guard case let .answeredCallback(answer) = effect else { return nil }
            return answer.text
        }
        #expect(answers == ["Button expired"])
        await bot.shutdown()
    }

    // MARK: - Scope

    @Test func userScopedButtonRejectsAnotherUserInTheSameChat() async throws {
        let pressed = TelerouteTestRecorder<String>()
        let router = Teleroute()
        router.command("menu") { _ in
            Reply("Yours").keyboard {
                Row {
                    TelerouteButton("Mine") { _ in
                        await pressed.record("ran")
                        return Edit("ok")
                    }
                }
            }
        }

        let (bot, telegram) = try Self.makeBot(
            router: router,
            expired: .answerCallback("Not for you")
        )
        let data = try await Self.renderKeyboard(bot: bot, telegram: telegram)
        telegram.reset()

        try await bot.test { client in
            _ = await client.execute(TelerouteTestSupport.makeCallbackUpdate(
                data: data[0],
                callbackUserId: 999
            ))
        }

        #expect(Self.answers(telegram) == ["Not for you"])
        #expect(await pressed.values.isEmpty)
        await bot.shutdown()
    }

    @Test func chatScopeAllowsAnotherUserButNotAnotherChat() async throws {
        let pressed = TelerouteTestRecorder<Int64>()
        let router = Teleroute()
        router.command("menu") { _ in
            Reply("Vote").keyboard {
                Row {
                    TelerouteButton("👍", scope: .chat) { context in
                        await pressed.record(context.userId ?? -1)
                        return Edit("voted")
                    }
                }
            }
        }

        let (bot, telegram) = try Self.makeBot(
            router: router,
            expired: .answerCallback("Out of scope")
        )
        let data = try await Self.renderKeyboard(bot: bot, telegram: telegram)
        telegram.reset()

        try await bot.test { client in
            // Same chat, different user → allowed.
            _ = await client.execute(TelerouteTestSupport.makeCallbackUpdate(
                data: data[0],
                callbackUserId: 999
            ))
        }
        #expect(await pressed.waitForCount(1) == [999])

        try await bot.test { client in
            // Different chat → rejected.
            _ = await client.execute(TelerouteTestSupport.makeCallbackUpdate(
                data: data[0],
                callbackUserId: 999,
                chatId: 42,
                updateId: 5
            ))
        }
        #expect(Self.answers(telegram).last == "Out of scope")
        #expect(await pressed.values == [999])
        await bot.shutdown()
    }

    @Test func anyoneScopeAcceptsAnyChatAndUser() async throws {
        let pressed = TelerouteTestRecorder<String>()
        let router = Teleroute()
        router.command("menu") { _ in
            Reply("Open").keyboard {
                Row {
                    TelerouteButton("Open", scope: .anyone) { _ in
                        await pressed.record("ran")
                        return Edit("opened")
                    }
                }
            }
        }

        let (bot, telegram) = try Self.makeBot(router: router)
        let data = try await Self.renderKeyboard(bot: bot, telegram: telegram)

        try await bot.test { client in
            _ = await client.execute(TelerouteTestSupport.makeCallbackUpdate(
                data: data[0],
                callbackUserId: 999,
                chatId: 42
            ))
        }
        #expect(await pressed.waitForCount(1) == ["ran"])
        await bot.shutdown()
    }

    // MARK: - Removing the button after a successful press

    @Test func removeButtonDropsOnlyThePressedOne() async throws {
        let (bot, telegram, calls) = try Self.makeLoggingBot { router in
            router.command("menu") { _ in
                Reply("Order 7").keyboard {
                    Row {
                        TelerouteButton("Claim", onSuccess: .removeButton) { _ in
                            AnswerCallback(text: "Claimed")
                        }
                        TelerouteButton("Details", url: "https://example.com")
                    }
                    Row { TelerouteButton("Close", onSuccess: .removeButton) { AnswerCallback() } }
                }
            }
        }

        let markup = try await Self.renderMarkup(bot: bot, telegram: telegram)
        let pressed = try #require(markup.inlineKeyboard[0][0].callbackData)

        try await bot.test { client in
            _ = await client.execute(Self.press(pressed, markup: markup))
        }

        let payload = try #require(await calls.waitForCall("editMessageReplyMarkup"))
        let rows = try #require(
            (payload["reply_markup"] as? [String: Any])?["inline_keyboard"] as? [[[String: Any]]]
        )
        // The URL sibling and the second row survive; only "Claim" is gone.
        #expect(rows.count == 2)
        #expect(rows[0].compactMap { $0["text"] as? String } == ["Details"])
        #expect(rows[1].compactMap { $0["text"] as? String } == ["Close"])
        await bot.shutdown()
    }

    @Test func removingTheLastButtonTakesTheKeyboardWithIt() async throws {
        let (bot, telegram, calls) = try Self.makeLoggingBot { router in
            router.command("menu") { _ in
                Reply("Only one").keyboard {
                    Row {
                        TelerouteButton("Claim", onSuccess: .removeButton) { AnswerCallback() }
                    }
                }
            }
        }

        let markup = try await Self.renderMarkup(bot: bot, telegram: telegram)
        let pressed = try #require(markup.inlineKeyboard[0][0].callbackData)

        try await bot.test { client in
            _ = await client.execute(Self.press(pressed, markup: markup))
        }

        let payload = try #require(await calls.waitForCall("editMessageReplyMarkup"))
        #expect(payload["reply_markup"] == nil)
        await bot.shutdown()
    }

    @Test func removeKeyboardTakesEveryButton() async throws {
        let (bot, telegram, calls) = try Self.makeLoggingBot { router in
            router.command("menu") { _ in
                Reply("Confirm?").keyboard {
                    Row {
                        TelerouteButton("Yes", onSuccess: .removeKeyboard) { AnswerCallback() }
                        TelerouteButton("No", onSuccess: .removeKeyboard) { AnswerCallback() }
                    }
                }
            }
        }

        let markup = try await Self.renderMarkup(bot: bot, telegram: telegram)
        let pressed = try #require(markup.inlineKeyboard[0][0].callbackData)

        try await bot.test { client in
            _ = await client.execute(Self.press(pressed, markup: markup))
        }

        let payload = try #require(await calls.waitForCall("editMessageReplyMarkup"))
        #expect(payload["reply_markup"] == nil)
        await bot.shutdown()
    }

    @Test func keyboardIsUntouchedByDefault() async throws {
        let (bot, telegram, calls) = try Self.makeLoggingBot { router in
            router.command("menu") { _ in
                Reply("Menu").keyboard {
                    Row { TelerouteButton("Ping") { AnswerCallback(text: "pong") } }
                }
            }
        }

        let markup = try await Self.renderMarkup(bot: bot, telegram: telegram)
        let pressed = try #require(markup.inlineKeyboard[0][0].callbackData)

        try await bot.test { client in
            _ = await client.execute(Self.press(pressed, markup: markup))
        }

        _ = await calls.waitForCall("answerCallbackQuery")
        #expect(await calls.waitForCall("editMessageReplyMarkup", retries: 3) == nil)
        await bot.shutdown()
    }

    @Test func anEditingResponseKeepsControlOfTheKeyboard() async throws {
        // `editMessageText` always decides the markup, so automatic removal
        // must stand aside rather than rewrite what the handler just set.
        let (bot, telegram, calls) = try Self.makeLoggingBot { router in
            router.command("menu") { _ in
                Reply("Order 7").keyboard {
                    Row {
                        TelerouteButton("Approve", onSuccess: .removeButton) { _ in
                            Edit("Approved").keyboard {
                                Row { TelerouteButton("Undo") { AnswerCallback() } }
                            }
                        }
                    }
                }
            }
        }

        let markup = try await Self.renderMarkup(bot: bot, telegram: telegram)
        let pressed = try #require(markup.inlineKeyboard[0][0].callbackData)

        try await bot.test { client in
            _ = await client.execute(Self.press(pressed, markup: markup))
        }

        _ = await calls.waitForCall("editMessageText")
        #expect(await calls.waitForCall("editMessageReplyMarkup", retries: 3) == nil)
        await bot.shutdown()
    }

    @Test func aThrowingHandlerLeavesTheButtonInPlace() async throws {
        let (bot, telegram, calls) = try Self.makeLoggingBot { router in
            router.command("menu") { _ in
                Reply("Menu").keyboard {
                    Row {
                        TelerouteButton("Boom", onSuccess: .removeButton) { _ -> AnswerCallback in
                            throw InlineActionProbeError.boom
                        }
                    }
                }
            }
        }

        let markup = try await Self.renderMarkup(bot: bot, telegram: telegram)
        let pressed = try #require(markup.inlineKeyboard[0][0].callbackData)

        try await bot.test { client in
            let result = await client.execute(Self.press(pressed, markup: markup))
            #expect(result.terminalEvent?.kind == .failed)
        }

        #expect(await calls.waitForCall("editMessageReplyMarkup", retries: 3) == nil)
        await bot.shutdown()
    }

    @Test func removePressedButtonWorksFromAnyCallbackHandler() async throws {
        let (bot, telegram, calls) = try Self.makeLoggingBot { router in
            router.callback("claim/{id}") { (context: TelerouteContext) -> Void in
                try await context.removePressedButton()
            }
            router.command("menu") { _ in
                Reply("Order").keyboard {
                    Row {
                        TelerouteButton("Claim") { InlineClaimCallback(id: "7") }
                        TelerouteButton("Details", url: "https://example.com")
                    }
                }
            }
        }

        let markup = try await Self.renderMarkup(bot: bot, telegram: telegram)

        try await bot.test { client in
            _ = await client.execute(Self.press("claim/7", markup: markup))
        }

        let payload = try #require(await calls.waitForCall("editMessageReplyMarkup"))
        let rows = try #require(
            (payload["reply_markup"] as? [String: Any])?["inline_keyboard"] as? [[[String: Any]]]
        )
        #expect(rows.flatMap { $0 }.compactMap { $0["text"] as? String } == ["Details"])
        await bot.shutdown()
    }

    @Test func removePressedButtonNeedsAReadableKeyboard() async throws {
        let recorder = TelerouteTestRecorder<String>()
        let router = Teleroute()
        router.callback("claim/{id}") { (context: TelerouteContext) -> Void in
            do {
                try await context.removePressedButton()
                await recorder.record("removed")
            } catch {
                await recorder.record(String(describing: error))
            }
        }

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            // An inline-mode press: no host message, so no keyboard to filter.
            _ = await client.execute(Update(updateId: 9, callbackQuery: CallbackQuery(
                id: "cb",
                from: User(id: 1, isBot: false, firstName: "T"),
                inlineMessageId: "inline-1",
                chatInstance: "ci",
                data: "claim/7"
            )))
        }

        #expect(
            await recorder.waitForCount(1).first?.contains("messageTargetMissing") == true
        )
        await bot.shutdown()
    }

    // MARK: - Store bounds

    @Test func storeEvictsTheOldestEntryOnceCapacityIsReached() {
        let store = TelerouteInlineActionStore(ttl: .seconds(600), capacity: 2, expired: .none)
        let first = store.insert(action: { _ in .none }, scope: .anyone, chatId: 1, userId: 1)
        let second = store.insert(action: { _ in .none }, scope: .anyone, chatId: 1, userId: 1)
        let third = store.insert(action: { _ in .none }, scope: .anyone, chatId: 1, userId: 1)

        #expect(store.count == 2)
        #expect(store.action(for: first, pressedBy: (1, 1)) == nil)
        #expect(store.action(for: second, pressedBy: (1, 1)) != nil)
        #expect(store.action(for: third, pressedBy: (1, 1)) != nil)
    }

    @Test func storeDropsEntriesPastTheirTTL() {
        let store = TelerouteInlineActionStore(ttl: .seconds(10), capacity: 10, expired: .none)
        let start = ContinuousClock.Instant.now
        let id = store.insert(
            action: { _ in .none },
            scope: .anyone,
            chatId: 1,
            userId: 1,
            now: start
        )

        #expect(store.action(for: id, pressedBy: (1, 1), now: start + .seconds(9)) != nil)
        #expect(store.action(for: id, pressedBy: (1, 1), now: start + .seconds(11)) == nil)
        #expect(store.count == 0)
    }

    @Test func generatedCallbackDataFitsTelegramsLimit() {
        let store = TelerouteInlineActionStore(ttl: .seconds(600), capacity: 10, expired: .none)
        let id = store.insert(action: { _ in .none }, scope: .anyone, chatId: 1, userId: 1)
        let data = "_ta/\(id)"

        #expect(data.utf8.count <= 64)
        #expect(data.contains("/") == true)          // exactly one separator
        #expect(id.contains("/") == false)           // no percent encoding needed
        #expect(id.addingPercentEncoding(withAllowedCharacters: .alphanumerics.union(.init(charactersIn: "-_"))) == id)
    }

    // MARK: - Configuration errors

    @Test func renderingAnInlineActionWithoutTheFeatureThrows() async throws {
        let recorder = TelerouteTestRecorder<String>()
        let router = Teleroute()
        router.command("menu") { (context: TelerouteContext) -> Void in
            do {
                _ = try context.keyboard {
                    Row { TelerouteButton("Nope") { Edit("x") } }
                }
                await recorder.record("rendered")
            } catch {
                await recorder.record(String(describing: error))
            }
        }

        // Default configuration leaves inline actions disabled.
        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.sendCommand("menu")
        }

        #expect(await recorder.waitForCount(1).first?.contains("inlineActionsDisabled") == true)
        await bot.shutdown()
    }

    @Test func renderingAnInlineActionWithoutARequestContextThrows() throws {
        let router = Teleroute()

        do {
            _ = try router.keyboard {
                Row { TelerouteButton("Nope") { Edit("x") } }
            }
            Issue.record("Expected inlineActionContextMissing")
        } catch let error as TelerouteError {
            guard case .inlineActionContextMissing = error else {
                Issue.record("Unexpected error \(error)")
                return
            }
        }
    }

    // MARK: - Route plumbing

    @Test func enablingInlineActionsAsksTelegramForCallbackQueries() throws {
        // A bot whose only callback route is the inline-action catch-all must
        // still receive presses: `allowed_updates` is derived once at start.
        let router = Teleroute()
        router.command("menu") { _ in "hi" }

        let (withActions, _) = try Self.makeBot(router: router)
        #expect(withActions.resolvedAllowedUpdates()?.contains("callback_query") == true)

        let plainRouter = Teleroute()
        plainRouter.command("menu") { _ in "hi" }
        let (plain, _) = try TelerouteTestSupport.makeTelerouteBot(router: plainRouter)
        #expect(plain.resolvedAllowedUpdates()?.contains("callback_query") == false)
    }

    @Test func routerMiddlewareSeesInlineActionPresses() async throws {
        let seen = TelerouteTestRecorder<String>()
        let router = Teleroute()
        router.middlewares.add(InlineActionProbeMiddleware(recorder: seen))
        router.command("menu") { _ in
            Reply("Menu").keyboard {
                Row { TelerouteButton("Go") { Edit("went") } }
            }
        }

        let (bot, telegram) = try Self.makeBot(router: router)
        let data = try await Self.renderKeyboard(bot: bot, telegram: telegram)

        try await bot.test { client in
            _ = await client.execute(TelerouteTestSupport.makeCallbackUpdate(data: data[0]))
        }

        // Once for the command that rendered the keyboard, once for the press.
        #expect(await seen.waitForCount(2).count == 2)
        await bot.shutdown()
    }

    @Test func inlineActionsAndTypedCallbacksCoexistInOneRow() async throws {
        // Regression on overload resolution: the callback-returning closure
        // and the action closure must not shadow each other.
        let router = Teleroute()
        router.callback(InlineProbeCallback.self) { _, _ in Edit("typed") }
        router.command("menu") { _ in
            Reply("Both").keyboard {
                Row {
                    TelerouteButton("Typed") { InlineProbeCallback(id: "7") }
                    TelerouteButton("Inline") { Edit("inline") }
                }
            }
        }

        let (bot, telegram) = try Self.makeBot(router: router)
        let data = try await Self.renderKeyboard(bot: bot, telegram: telegram)

        #expect(data[0] == "probe/7")
        #expect(data[1].hasPrefix("_ta/"))
        await bot.shutdown()
    }

    // MARK: - Helpers

    /// A bot whose transport records every operation, so keyboard edits can be
    /// asserted on the wire (the recording transport ignores
    /// `editMessageReplyMarkup`).
    private static func makeLoggingBot(
        configure: (Teleroute<TelerouteContext>) -> Void
    ) throws -> (TelerouteBot, TelerouteRecordingTransport, TelerouteEditCallLog) {
        let router = Teleroute()
        configure(router)
        let calls = TelerouteEditCallLog()
        let telegram = TelerouteRecordingTransport { operationID, body in
            calls.record(operation: operationID, body: body)
            return (
                HTTPResponse(status: .ok),
                try JSONSerialization.data(withJSONObject: ["ok": true, "result": true])
            )
        }
        let bot = try TelerouteBot(
            token: TelerouteTestSupport.testToken,
            router: router,
            logger: .init(label: "tests.inline.completion"),
            configuration: .init(
                replayProtectionStorage: nil,
                inlineActions: .enabled()
            ),
            transport: telegram,
            rateLimit: nil
        )
        return (bot, telegram, calls)
    }

    /// Sends `/menu` and returns the keyboard it rendered.
    private static func renderMarkup(
        bot: TelerouteBot,
        telegram: TelerouteRecordingTransport
    ) async throws -> InlineKeyboardMarkup {
        try await bot.test { client in
            _ = await client.sendCommand("menu")
        }
        guard case let .sentMessage(message) = telegram.effects.first,
              case let .InlineKeyboardMarkup(markup) = message.replyMarkup
        else {
            Issue.record("Expected a message with an inline keyboard")
            return .init(rows: [])
        }
        return markup
    }

    /// A press on a host message that still carries `markup`, which is what
    /// Telegram sends and what button removal reads.
    private static func press(_ data: String, markup: InlineKeyboardMarkup) -> Update {
        let user = User(id: 1, isBot: false, firstName: "Test")
        let host = Message(
            messageId: 1,
            from: user,
            date: 1,
            chat: Chat(id: 1, type: .private),
            text: "host",
            replyMarkup: markup
        )
        return Update(updateId: 3, callbackQuery: CallbackQuery(
            id: "callback-id",
            from: user,
            message: .Message(host),
            chatInstance: "chat-instance",
            data: data
        ))
    }

    private static func makeBot(
        router: Teleroute<TelerouteContext>,
        ttl: Duration = .seconds(1800),
        capacity: Int = 10_000,
        expired: TelerouteResponse = .answerCallback("This button has expired.")
    ) throws -> (TelerouteBot, TelerouteRecordingTransport) {
        try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(
                replayProtectionStorage: nil,
                inlineActions: .enabled(ttl: ttl, capacity: capacity, expired: expired)
            )
        )
    }

    /// Sends `/menu`, then returns the `callback_data` of the rendered row.
    private static func renderKeyboard(
        bot: TelerouteBot,
        telegram: TelerouteRecordingTransport,
        chatId: Int64 = 1
    ) async throws -> [String] {
        try await bot.test { client in
            _ = await client.sendCommand("menu", chatId: chatId)
        }
        guard case let .sentMessage(message) = telegram.effects.first,
              case let .InlineKeyboardMarkup(markup) = message.replyMarkup
        else {
            Issue.record("Expected a message with an inline keyboard, got \(telegram.effects)")
            return []
        }
        return markup.inlineKeyboard.flatMap { $0 }.compactMap(\.callbackData)
    }

    private static func edit(
        _ telegram: TelerouteRecordingTransport
    ) -> TelerouteRecordedEdit? {
        telegram.effects.compactMap { effect -> TelerouteRecordedEdit? in
            guard case let .editedMessage(edit) = effect else { return nil }
            return edit
        }.last
    }

    private static func edits(_ telegram: TelerouteRecordingTransport) -> [String] {
        telegram.effects.compactMap { effect in
            guard case let .editedMessage(edit) = effect else { return nil }
            return edit.text
        }
    }

    private static func answers(_ telegram: TelerouteRecordingTransport) -> [String] {
        telegram.effects.compactMap { effect in
            guard case let .answeredCallback(answer) = effect else { return nil }
            return answer.text
        }
    }
}

// MARK: - Fixtures

private struct InlineActionProbeMiddleware: TelerouteMiddleware {
    let recorder: TelerouteTestRecorder<String>

    func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> TelerouteResponse
    ) async throws -> TelerouteResponse {
        await self.recorder.record(context.callbackData ?? "no-callback")
        return try await next(context)
    }
}

@TelerouteCallback("probe/{id}")
private struct InlineProbeCallback {
    let id: String
}

@TelerouteCallback("claim/{id}")
private struct InlineClaimCallback {
    let id: String
}

private enum InlineActionProbeError: Error {
    case boom
}
