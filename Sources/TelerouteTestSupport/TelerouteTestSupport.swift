import Foundation
import SwiftTelegramBot
import Teleroute

/// Test doubles and helpers for users (and the Teleroute test suite) to exercise
/// routes, middleware, and flows without a live Telegram connection.
///
/// Add `TelerouteTestSupport` to your test target dependencies, then use
/// ``TelerouteTestSupport/makeBot(client:)`` to build a router backed by a
/// ``TelerouteStubClient`` or your own `TGClientPrtcl` fake.

/// A no-op `TGClientPrtcl` that throws on every network call.
///
/// Use it for routing/middleware tests that never reach the Telegram API. For
/// tests that must observe outgoing API calls (for example `setMyCommands`),
/// subclass or use ``TelerouteRecordingCommandsClient`` instead.
public struct TelerouteStubClient: TGClientPrtcl {
    public init() {}

    public func post<Params: Encodable, Response: Decodable>(
        _ url: URL,
        params: Params?,
        as mediaType: HTTPMediaType?
    ) async throws -> Response {
        throw TelerouteTestNetworkError.unexpectedCall
    }

    public func post<Response: Decodable>(_ url: URL) async throws -> Response {
        throw TelerouteTestNetworkError.unexpectedCall
    }
}

/// Errors thrown by the built-in test doubles.
public enum TelerouteTestNetworkError: Error, Equatable, Sendable {
    /// Raised by ``TelerouteStubClient`` on any API call.
    case unexpectedCall
}

/// Records values of any `Sendable` type for async test assertions.
public actor TelerouteTestRecorder<Value: Sendable> {
    private var storage: [Value] = []

    public init() {}

    /// Appends a value to the recorder.
    public func record(_ value: Value) {
        self.storage.append(value)
    }

    /// Removes all recorded values.
    public func reset() {
        self.storage.removeAll()
    }

    /// All values recorded so far.
    public var values: [Value] {
        self.storage
    }

    /// Polls until at least `count` values have been recorded, returning them.
    public func waitForCount(_ count: Int, retries: Int = 50) async -> [Value] {
        for _ in 0..<retries {
            if self.storage.count >= count {
                return self.storage
            }
            try? await Task.sleep(for: .milliseconds(10))
        }
        return self.storage
    }
}

/// A flow storage implementation backed by an in-process dictionary, useful for
/// asserting on session state in tests without touching `TelerouteInMemoryFlowStorage`.
public actor TelerouteMockFlowStorage: TelerouteFlowStorage {
    private var sessions: [TelerouteFlowKey: TelerouteFlowSession] = [:]

    public init() {}

    public func session(for key: TelerouteFlowKey) async -> TelerouteFlowSession? {
        self.sessions[key]
    }

    public func setSession(_ session: TelerouteFlowSession, for key: TelerouteFlowKey) async {
        self.sessions[key] = session
    }

    public func removeSession(for key: TelerouteFlowKey) async {
        self.sessions.removeValue(forKey: key)
    }

    /// Number of sessions currently stored.
    public var count: Int {
        self.sessions.count
    }

    /// Whether a session exists for the given key.
    public func contains(_ key: TelerouteFlowKey) async -> Bool {
        self.sessions[key] != nil
    }
}

/// Builds a `TGBot` suitable for tests, optionally backed by a custom client.
///
/// The bot uses a long-polling connection type but never starts polling unless
/// `bot.start()` is invoked, so it is safe to construct in routing tests.
public enum TelerouteTestSupport {
    /// Creates a bot backed by the supplied client (defaults to ``TelerouteStubClient``).
    public static func makeBot(
        client: any TGClientPrtcl = TelerouteStubClient(),
        label: String = "teleroute.tests.bot"
    ) async throws -> TGBot {
        try await TGBot(
            connectionType: .longpolling(),
            tgClient: client,
            botId: "123456:test-token",
            log: .init(label: label)
        )
    }

    /// Builds a synthetic command update (`/name args`).
    public static func makeCommandUpdate(
        text: String,
        chatType: TGChatType = .private,
        userId: Int64 = 1,
        chatId: Int64 = 1,
        updateId: Int = 1
    ) -> TGUpdate {
        let commandToken = String(text.split(maxSplits: 1, whereSeparator: \.isWhitespace).first ?? "")
        let entity = TGMessageEntity(type: .botCommand, offset: 0, length: commandToken.utf16.count)
        let message = TGMessage(
            messageId: 1,
            from: TGUser(id: userId, isBot: false, firstName: "Test", username: "tester"),
            date: 0,
            chat: TGChat(id: chatId, type: chatType, firstName: "Test"),
            text: text,
            entities: [entity]
        )
        return TGUpdate(updateId: updateId, message: message)
    }

    /// Builds a synthetic plain-text message update.
    public static func makeMessageUpdate(
        text: String,
        chatType: TGChatType = .private,
        userId: Int64 = 1,
        chatId: Int64 = 1,
        updateId: Int = 2
    ) -> TGUpdate {
        let message = TGMessage(
            messageId: 2,
            from: TGUser(id: userId, isBot: false, firstName: "Test", username: "tester"),
            date: 0,
            chat: TGChat(id: chatId, type: chatType, firstName: "Test"),
            text: text
        )
        return TGUpdate(updateId: updateId, message: message)
    }

    /// Builds a synthetic callback-query update for inline-button presses.
    public static func makeCallbackUpdate(
        data: String,
        chatType: TGChatType = .private,
        messageUserId: Int64 = 1,
        messageIsBot: Bool = false,
        callbackUserId: Int64 = 1,
        chatId: Int64 = 1,
        updateId: Int = 3
    ) -> TGUpdate {
        let message = TGMessage(
            messageId: 1,
            from: TGUser(id: messageUserId, isBot: messageIsBot, firstName: "Test", username: "tester"),
            date: 0,
            chat: TGChat(id: chatId, type: chatType, firstName: "Test"),
            text: "callback host"
        )
        let callbackQuery = TGCallbackQuery(
            id: "callback-id",
            from: TGUser(id: callbackUserId, isBot: false, firstName: "Test", username: "tester"),
            message: .message(message),
            chatInstance: "chat-instance",
            data: data
        )
        return TGUpdate(updateId: updateId, callbackQuery: callbackQuery)
    }
}
