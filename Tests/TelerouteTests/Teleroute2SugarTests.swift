import Foundation
import HTTPTypes
import Synchronization
import Testing
import Teleroute
import TelerouteMacros
import TelerouteTestSupport

/// Tests for Phase-4 sugar: typed macros, keyboard DSL, real replies,
/// text formatting, and the consolidated helper surface.
@Suite struct Teleroute2SugarTests {
    @Test func typedMacroDecodesNumbersBoolsAndDefaults() throws {
        let match = TelerouteCommandMatch(
            name: "transfer",
            rawValue: "/transfer",
            mentionedBotUsername: nil,
            argumentsText: "42 99.5 true",
            arguments: ["42", "99.5", "true"]
        )
        let command = try TypedTransferCommand(command: match)
        #expect(command.userId == 42)
        #expect(command.amount == 99.5)
        #expect(command.instant == true)
        #expect(command.comment == nil)

        let defaulted = try TypedTransferCommand(command: .init(
            name: "transfer",
            rawValue: "/transfer",
            mentionedBotUsername: nil,
            argumentsText: "7",
            arguments: ["7"]
        ))
        #expect(defaulted.amount == 1.0)
        #expect(defaulted.instant == false)
    }

    @Test func typedMacroRejectsMalformedNumbers() {
        let match = TelerouteCommandMatch(
            name: "transfer",
            rawValue: "/transfer",
            mentionedBotUsername: nil,
            argumentsText: "not-a-number",
            arguments: ["not-a-number"]
        )
        do {
            _ = try TypedTransferCommand(command: match)
            Issue.record("Expected invalidParameter error")
        } catch let error as TelerouteError {
            guard case let .invalidParameter(name, value) = error else {
                Issue.record("Unexpected error \(error)")
                return
            }
            #expect(name == "userId")
            #expect(value == "not-a-number")
        } catch {
            Issue.record("Unexpected error \(error)")
        }
    }

    @Test func typedCallbackMacroRoundTripsNonStringParameters() throws {
        let callback = TypedPageCallback(page: 3, section: "news")
        #expect(callback.parameters == ["page": "3", "section": "news"])

        let decoded = try TypedPageCallback(
            parameters: .init(["page": "3", "section": "news"])
        )
        #expect(decoded.page == 3)
        #expect(decoded.section == "news")
    }

    @Test func keyboardBuilderComposesRowsAndValidatesScope() throws {
        let router = Teleroute()
        let route = router.callback(SugarOpenCallback.self) { _, _ in "opened" }

        let markup = try router.keyboard {
            Row {
                route.button(SugarOpenCallback(id: "1"), "Open")
                TelerouteButton.url("Docs", "https://example.com")
            }
            TelerouteButton.switchInlineQuery("Share", query: "cats")
        }

        #expect(markup.inlineKeyboard.count == 2)
        #expect(markup.inlineKeyboard[0][0].callbackData == "open/1")
        #expect(markup.inlineKeyboard[0][1].url == "https://example.com")
        #expect(markup.inlineKeyboard[1][0].switchInlineQuery == "cats")
    }

    @Test func replyKeyboardBuilderProducesRequestButtons() {
        let keyboard = ReplyKeyboardMarkup(resize: true) {
            KeyRow {
                KeyButton("Share contact").requestContact()
                "Cancel"
            }
        }
        #expect(keyboard.resizeKeyboard == true)
        #expect(keyboard.keyboard[0][0].requestContact == true)
        #expect(keyboard.keyboard[0][1].text == "Cancel")
    }

    @Test func replyAttachesReplyParametersOnTheWire() async throws {
        let captured = Mutex<Data?>(nil)
        let transport = SugarCapturingTransport { operationID, body in
            if operationID == "sendMessage" {
                captured.withLock { $0 = body }
            }
        }
        let router = Teleroute()
        router.command("hi") { _ in Reply("hello").quoting("hi") }
        let bot = try TelerouteBot(
            token: TelerouteTestSupport.testToken,
            router: router,
            logger: .init(label: "tests.reply"),
            configuration: .init(replayProtectionStorage: nil),
            transport: transport,
            rateLimit: nil
        )
        try await bot.test { client in
            _ = await client.sendCommand("hi", updateId: 4_001)
        }
        let body = captured.withLock { $0 }
        let json = try JSONSerialization.jsonObject(with: body ?? Data()) as! [String: Any]
        let replyParameters = json["reply_parameters"] as? [String: Any]
        #expect(replyParameters?["message_id"] as? Int == 1)
        #expect(replyParameters?["quote"] as? String == "hi")
        await bot.shutdown()
    }

    @Test func telegramTextEscapesAndFormats() {
        #expect(TelegramText.escapeHTML("a < b & c") == "a &lt; b &amp; c")
        #expect(TelegramText.escapeMarkdownV2("a_b.c!") == #"a\_b\.c\!"#)
        #expect(TelegramText.bold("x<y") == "<b>x&lt;y</b>")
        #expect(TelegramText.link("Site", "https://e.com") == #"<a href="https://e.com">Site</a>"#)
        #expect(TelegramText.mention("User", userId: 5) == #"<a href="tg://user?id=5">User</a>"#)
    }

    @Test func customContextsHaveFullHelperSurface() async throws {
        let router = Teleroute(context: SugarAppContext.self)
        router.command("photo") { context in
            // Media helper available directly on the custom context.
            try await context.sendPhoto(.fileID("f-1"), caption: "pic")
        }

        let telegram = TelerouteRecordingTransport(fallback: { operationID, _ in
            guard operationID == "sendPhoto" else {
                throw TelerouteTestNetworkError.unsupportedMethod(operationID)
            }
            var response = HTTPResponse(status: .ok)
            response.headerFields[.contentType] = "application/json"
            let body = #"{"ok":true,"result":{"message_id":9,"date":1,"chat":{"id":1,"type":"private"}}}"#
            return (response, Data(body.utf8))
        })
        let bot = try TelerouteBot(
            token: TelerouteTestSupport.testToken,
            router: router,
            logger: .init(label: "tests.helpers"),
            configuration: .init(replayProtectionStorage: nil),
            transport: telegram,
            rateLimit: nil
        )
        try await bot.test { client in
            let result = await client.sendCommand("photo", updateId: 4_002)
            #expect(result.terminalEvent?.kind == .handled)
        }
        await bot.shutdown()
    }

    @Test func chatIdLiteralsResolveTargets() async throws {
        let router = Teleroute()
        router.command("post") { context in
            try await context.send("news", to: "@channel")
        }
        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.sendCommand("post", updateId: 4_003)
        }
        guard case let .sentMessage(message) = telegram.effects.first else {
            Issue.record("Expected message")
            return
        }
        #expect(message.chatId == .username("@channel"))
        await bot.shutdown()
    }
}

@TelerouteCommand("transfer")
private struct TypedTransferCommand {
    let userId: Int64
    var amount: Double = 1.0
    var instant: Bool = false
    let comment: String?
}

@TelerouteCallback("pages/{page}/{section}")
private struct TypedPageCallback {
    let page: Int
    let section: String
}

@TelerouteCallback("open/{id}")
private struct SugarOpenCallback {
    let id: String
}

private struct SugarAppContext: TelerouteInitializableRequestContext {
    let coreContext: TelerouteContext

    init(source: TelerouteContextSource) {
        self.coreContext = source.coreContext
    }
}

private struct SugarCapturingTransport: TelegramTransport {
    let onRequest: @Sendable (String, Data) -> Void

    init(onRequest: @escaping @Sendable (String, Data) -> Void) {
        self.onRequest = onRequest
    }

    func send(
        _ request: HTTPRequest,
        body: Data?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, Data) {
        let data = body ?? Data()
        self.onRequest(operationID, data)
        var response = HTTPResponse(status: .ok)
        response.headerFields[.contentType] = "application/json"
        let json: String
        switch operationID {
        case "sendMessage":
            json = #"{"ok":true,"result":{"message_id":2,"date":1,"chat":{"id":1,"type":"private"},"text":"x"}}"#
        default:
            json = #"{"ok":true,"result":true}"#
        }
        return (response, Data(json.utf8))
    }
}
