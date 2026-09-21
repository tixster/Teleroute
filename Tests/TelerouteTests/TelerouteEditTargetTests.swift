import Foundation
import HTTPTypes
import Synchronization
import Testing
import TelerouteTestSupport
@_spi(Testing) @testable import Teleroute

/// Tests that one `Edit` reaches whichever message the update actually
/// carries: an ordinary one, an inline-mode one, or one the bot can no longer
/// read.
@Suite struct TelerouteEditTargetTests {

    // MARK: - Target resolution

    @Test func ordinaryCallbackResolvesToItsChatAndMessage() throws {
        let context = try Self.context(for: Self.callbackUpdate())

        #expect(
            try context.resolvedEditTarget()
                == .message(chatId: .id(555), messageId: 42)
        )
    }

    @Test func inlineModeCallbackResolvesToItsInlineMessageIdentifier() throws {
        let context = try Self.context(for: Self.inlineCallbackUpdate())

        #expect(try context.resolvedEditTarget() == .inline(messageId: "inline-42"))
        // An inline message has no chat at all, which is exactly why the
        // chat/message pair cannot be used here.
        #expect(context.chatId == nil)
        #expect(context.message == nil)
    }

    @Test func inaccessibleMessageStillResolvesToAnEditableTarget() throws {
        let context = try Self.context(for: Self.inaccessibleCallbackUpdate())

        // `message` is nil — the bot cannot read the contents — but the chat
        // and id are there, so the edit is attempted and Telegram decides.
        #expect(context.message == nil)
        #expect(
            try context.resolvedEditTarget()
                == .message(chatId: .id(777), messageId: 9)
        )
    }

    @Test func explicitOverridesWinOverTheUpdate() throws {
        let context = try Self.context(for: Self.callbackUpdate())

        #expect(
            try context.resolvedEditTarget(messageId: 7)
                == .message(chatId: .id(555), messageId: 7)
        )
        #expect(
            try context.resolvedEditTarget(messageId: 7, in: "@channel")
                == .message(chatId: "@channel", messageId: 7)
        )
    }

    @Test func updateWithoutAnyMessageStillThrows() throws {
        // An update carrying neither a message nor a callback query.
        let context = try Self.context(for: Update(updateId: 1))

        #expect(throws: TelerouteError.self) {
            _ = try context.resolvedEditTarget()
        }
    }

    // MARK: - What actually goes on the wire

    @Test func editOnAnInlineMessageSendsInlineMessageId() async throws {
        let calls = TelerouteEditCallLog()
        let router = Teleroute()
        router.callback("open/{id}") { context in
            Edit("Edited")
        }

        let bot = try TelerouteBot(
            token: TelerouteTestSupport.testToken,
            router: router,
            configuration: .init(replayProtectionStorage: nil),
            transport: TelerouteEditCapturingTransport(log: calls),
            rateLimit: nil
        )
        try await bot.test { client in
            _ = await client.execute(Self.inlineCallbackUpdate())
        }

        let payload = try #require(await calls.waitForCall("editMessageText"))
        #expect(payload["inline_message_id"] as? String == "inline-42")
        #expect(payload["chat_id"] == nil)
        #expect(payload["message_id"] == nil)
        #expect(payload["text"] as? String == "Edited")
        await bot.shutdown()
    }

    @Test func editOnAnOrdinaryMessageSendsChatAndMessageId() async throws {
        let calls = TelerouteEditCallLog()
        let router = Teleroute()
        router.callback("open/{id}") { context in
            Edit("Edited")
        }

        let bot = try TelerouteBot(
            token: TelerouteTestSupport.testToken,
            router: router,
            configuration: .init(replayProtectionStorage: nil),
            transport: TelerouteEditCapturingTransport(log: calls),
            rateLimit: nil
        )
        try await bot.test { client in
            _ = await client.execute(Self.callbackUpdate())
        }

        let payload = try #require(await calls.waitForCall("editMessageText"))
        #expect(payload["chat_id"] as? Int64 == 555)
        #expect(payload["message_id"] as? Int64 == 42)
        #expect(payload["inline_message_id"] == nil)
        await bot.shutdown()
    }

    @Test func editReplyMarkupFollowsTheSameTarget() async throws {
        let calls = TelerouteEditCallLog()
        let router = Teleroute()
        router.callback("open/{id}") { (context: TelerouteContext) -> Void in
            try await context.editReplyMarkup(InlineKeyboardMarkup(rows: []))
        }

        let bot = try TelerouteBot(
            token: TelerouteTestSupport.testToken,
            router: router,
            configuration: .init(replayProtectionStorage: nil),
            transport: TelerouteEditCapturingTransport(log: calls),
            rateLimit: nil
        )
        try await bot.test { client in
            _ = await client.execute(Self.inlineCallbackUpdate())
        }

        let payload = try #require(await calls.waitForCall("editMessageReplyMarkup"))
        #expect(payload["inline_message_id"] as? String == "inline-42")
        #expect(payload["chat_id"] == nil)
        await bot.shutdown()
    }

    @Test func editOnAnInaccessibleMessageIsAttemptedRatherThanRefused() async throws {
        let calls = TelerouteEditCallLog()
        let router = Teleroute()
        router.callback("open/{id}") { context in
            Edit("Edited")
        }

        let bot = try TelerouteBot(
            token: TelerouteTestSupport.testToken,
            router: router,
            configuration: .init(replayProtectionStorage: nil),
            transport: TelerouteEditCapturingTransport(log: calls),
            rateLimit: nil
        )
        try await bot.test { client in
            _ = await client.execute(Self.inaccessibleCallbackUpdate())
        }

        let payload = try #require(await calls.waitForCall("editMessageText"))
        #expect(payload["chat_id"] as? Int64 == 777)
        #expect(payload["message_id"] as? Int64 == 9)
        await bot.shutdown()
    }

    // MARK: - Fixtures

    private static func context(for update: Update) throws -> TelerouteContext {
        TelerouteContext(
            bot: try TelerouteTestSupport.makeClient(),
            update: update
        )
    }

    private static func user(_ id: Int64 = 1) -> User {
        User(id: id, isBot: false, firstName: "Test")
    }

    /// A button press on an ordinary message in chat 555.
    static func callbackUpdate() -> Update {
        let message = Message(
            messageId: 42,
            from: self.user(),
            date: 1,
            chat: Chat(id: 555, type: .private),
            text: "host"
        )
        return Update(updateId: 1, callbackQuery: CallbackQuery(
            id: "cb",
            from: self.user(),
            message: .Message(message),
            chatInstance: "ci",
            data: "open/7"
        ))
    }

    /// A button press on a message sent through inline mode: no chat, no
    /// message id, only `inline_message_id`.
    static func inlineCallbackUpdate() -> Update {
        Update(updateId: 2, callbackQuery: CallbackQuery(
            id: "cb-inline",
            from: self.user(),
            inlineMessageId: "inline-42",
            chatInstance: "ci",
            data: "open/7"
        ))
    }

    /// A button press on a message the bot can no longer read. Telegram marks
    /// these with `date == 0` while still supplying chat and id.
    static func inaccessibleCallbackUpdate() -> Update {
        Update(updateId: 3, callbackQuery: CallbackQuery(
            id: "cb-gone",
            from: self.user(),
            message: .InaccessibleMessage(InaccessibleMessage(
                chat: Chat(id: 777, type: .private),
                messageId: 9,
                date: 0
            )),
            chatInstance: "ci",
            data: "open/7"
        ))
    }
}

/// Records every request body by operation, for assertions on the exact wire
/// fields — the recording transport does not capture `inline_message_id`.
final class TelerouteEditCallLog: Sendable {
    private let calls = Mutex<[(operation: String, body: Data)]>([])

    func record(operation: String, body: Data) {
        self.calls.withLock { $0.append((operation, body)) }
    }

    func waitForCall(_ operation: String, retries: Int = 50) async -> [String: Any]? {
        for _ in 0..<retries {
            let match = self.calls.withLock { calls in
                calls.first { $0.operation == operation }?.body
            }
            if let match {
                return try? JSONSerialization.jsonObject(with: match) as? [String: Any]
            }
            try? await Task.sleep(for: .milliseconds(10))
        }
        return nil
    }
}

struct TelerouteEditCapturingTransport: TelegramTransport {
    let log: TelerouteEditCallLog

    func send(
        _ request: HTTPRequest,
        body: Data?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, Data) {
        self.log.record(operation: operationID, body: body ?? Data())
        return (
            HTTPResponse(status: .ok),
            try JSONSerialization.data(withJSONObject: ["ok": true, "result": true])
        )
    }
}
