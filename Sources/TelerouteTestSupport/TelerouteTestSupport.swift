import Foundation
import SwiftTelegramBot
import Synchronization
import Teleroute

/// Test doubles and helpers for users (and the Teleroute test suite) to exercise
/// routes, middleware, and flows without a live Telegram connection.
///
/// Add `TelerouteTestSupport` to your test target dependencies, then use
/// ``TelerouteTestSupport/makeTelerouteBot(router:configuration:label:)`` for a
/// complete in-process routed bot or ``TelerouteTestSupport/makeBot(client:connectionType:label:)``
/// with your own `TGClientPrtcl` fake.

/// A no-op `TGClientPrtcl` that throws on every network call.
///
/// Use it for routing/middleware tests that never reach the Telegram API. For
/// tests that must observe outgoing API calls, use
/// ``TelerouteRecordingClient`` instead.
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
    /// Raised when the recording client does not know how to fake a Telegram
    /// method's response.
    case unsupportedMethod(String)
    /// Raised when a Telegram client response type is not the expected type.
    case unexpectedResponseType(String)
}

/// Text message sent by a route during an in-process test.
public struct TelerouteRecordedMessage: Sendable {
    public let chatId: TGChatId
    public let text: String
    public let replyMarkup: TGReplyMarkup?
}

/// Message edit performed by a route during an in-process test.
public struct TelerouteRecordedEdit: Sendable {
    public let chatId: TGChatId?
    public let messageId: Int?
    public let text: String
    public let replyMarkup: TGInlineKeyboardMarkup?
}

/// Callback-query answer performed during an in-process test.
public struct TelerouteRecordedCallbackAnswer: Sendable {
    public let callbackQueryId: String
    public let text: String?
    public let showAlert: Bool?
}

/// Telegram side effect captured by ``TelerouteRecordingClient``.
public enum TelerouteRecordedEffect: Sendable {
    case sentMessage(TelerouteRecordedMessage)
    case editedMessage(TelerouteRecordedEdit)
    case answeredCallback(TelerouteRecordedCallbackAnswer)
    case commandMenuUpdated
}

/// In-memory Telegram client that records common text, keyboard, callback, and
/// command-menu operations while returning synthetic successful responses.
public final class TelerouteRecordingClient: TGClientPrtcl, Sendable {
    private struct State: Sendable {
        var effects: [TelerouteRecordedEffect] = []
        var nextMessageId = 1
    }

    private let state = Mutex(State())

    public init() {}

    /// Effects recorded in request order.
    public var effects: [TelerouteRecordedEffect] {
        self.state.withLock { $0.effects }
    }

    /// Removes all previously recorded effects.
    public func reset() {
        self.state.withLock { $0.effects.removeAll(keepingCapacity: true) }
    }

    public func post<Params: Encodable, Response: Decodable>(
        _ url: URL,
        params: Params?,
        as mediaType: HTTPMediaType?
    ) async throws -> Response {
        let method = url.lastPathComponent
        let data = try params.map { try JSONEncoder().encode($0) }

        switch method {
        case "sendMessage":
            let value = try self.decode(RecordedSendMessageParams.self, from: data)
            self.state.withLock {
                $0.effects.append(
                    .sentMessage(
                        .init(
                            chatId: value.chatId,
                            text: value.text,
                            replyMarkup: value.replyMarkup
                        )
                    )
                )
            }
            let message = self.makeMessage(chatId: value.chatId, text: value.text)
            return try self.cast(message, method: method)

        case "editMessageText":
            let value = try self.decode(RecordedEditMessageParams.self, from: data)
            self.state.withLock {
                $0.effects.append(
                    .editedMessage(
                        .init(
                            chatId: value.chatId,
                            messageId: value.messageId,
                            text: value.text,
                            replyMarkup: value.replyMarkup
                        )
                    )
                )
            }
            return try self.cast(TGMessageOrBool.bool(true), method: method)

        case "answerCallbackQuery":
            let value = try self.decode(RecordedAnswerCallbackParams.self, from: data)
            self.state.withLock {
                $0.effects.append(
                    .answeredCallback(
                        .init(
                            callbackQueryId: value.callbackQueryId,
                            text: value.text,
                            showAlert: value.showAlert
                        )
                    )
                )
            }
            return try self.cast(true, method: method)

        case "setMyCommands", "deleteMyCommands":
            self.state.withLock { $0.effects.append(.commandMenuUpdated) }
            return try self.cast(true, method: method)

        case "setWebhook", "deleteWebhook":
            return try self.cast(true, method: method)

        default:
            throw TelerouteTestNetworkError.unsupportedMethod(method)
        }
    }

    public func post<Response: Decodable>(_ url: URL) async throws -> Response {
        throw TelerouteTestNetworkError.unsupportedMethod(url.lastPathComponent)
    }

    private func decode<Value: Decodable>(
        _ type: Value.Type,
        from data: Data?
    ) throws -> Value {
        guard let data else {
            throw TelerouteTestNetworkError.unexpectedCall
        }
        return try JSONDecoder().decode(type, from: data)
    }

    private func cast<Value, Response: Decodable>(
        _ value: Value,
        method: String
    ) throws -> Response {
        guard let response = value as? Response else {
            throw TelerouteTestNetworkError.unexpectedResponseType(method)
        }
        return response
    }

    private func makeMessage(chatId: TGChatId, text: String) -> TGMessage {
        let resolvedChatId: Int64 = switch chatId {
        case let .chat(value): value
        case .username, .undefined: 0
        }
        let messageId = self.state.withLock { state in
            defer { state.nextMessageId += 1 }
            return state.nextMessageId
        }
        return TGMessage(
            messageId: messageId,
            from: TGUser(id: 0, isBot: true, firstName: "Teleroute"),
            date: 0,
            chat: TGChat(id: resolvedChatId, type: .private),
            text: text
        )
    }
}

private struct RecordedSendMessageParams: Decodable {
    let chatId: TGChatId
    let text: String
    let replyMarkup: TGReplyMarkup?

    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case text
        case replyMarkup = "reply_markup"
    }
}

private struct RecordedEditMessageParams: Decodable {
    let chatId: TGChatId?
    let messageId: Int?
    let text: String
    let replyMarkup: TGInlineKeyboardMarkup?

    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case messageId = "message_id"
        case text
        case replyMarkup = "reply_markup"
    }
}

private struct RecordedAnswerCallbackParams: Decodable {
    let callbackQueryId: String
    let text: String?
    let showAlert: Bool?

    enum CodingKeys: String, CodingKey {
        case callbackQueryId = "callback_query_id"
        case text
        case showAlert = "show_alert"
    }
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

    @discardableResult
    public func updateSession(
        for key: TelerouteFlowKey,
        _ mutation: TelerouteFlowSessionMutation
    ) async rethrows -> TelerouteFlowSession? {
        let updated = try mutation(self.sessions[key])
        self.sessions[key] = updated
        return updated
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
/// The default connection is long polling, but it never starts unless
/// `bot.start()` is invoked. Tests may supply a webhook connection explicitly.
public enum TelerouteTestSupport {
    /// Creates a bot backed by the supplied client (defaults to ``TelerouteStubClient``).
    public static func makeBot(
        client: any TGClientPrtcl = TelerouteStubClient(),
        connectionType: TGConnectionType = .longpolling(),
        label: String = "teleroute.tests.bot"
    ) async throws -> TGBot {
        try await TGBot(
            connectionType: connectionType,
            tgClient: client,
            botId: "123456:test-token",
            log: .init(label: label)
        )
    }

    /// Creates a routed bot and recording Telegram client for in-process tests.
    public static func makeTelerouteBot<Context: TelerouteRequestContext>(
        router: Teleroute<Context>,
        configuration: TelerouteBot.Configuration = .init(
            replayProtectionStorage: nil
        ),
        label: String = "teleroute.tests.bot"
    ) async throws -> (
        bot: TelerouteBot,
        telegram: TelerouteRecordingClient
    ) {
        let telegram = TelerouteRecordingClient()
        let transport = try await self.makeBot(
            client: telegram,
            label: "\(label).transport"
        )
        let bot = TelerouteBot(
            bot: transport,
            router: router,
            logger: .init(label: label),
            configuration: configuration
        )
        return (bot, telegram)
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

public extension TelerouteBotTestClient {
    /// Sends a synthetic `/command arguments` update.
    func sendCommand(
        _ text: String,
        chatType: TGChatType = .private,
        userId: Int64 = 1,
        chatId: Int64 = 1,
        updateId: Int = 1
    ) async -> TelerouteBotTestResult {
        let command = text.hasPrefix("/") ? text : "/\(text)"
        return await self.execute(
            TelerouteTestSupport.makeCommandUpdate(
                text: command,
                chatType: chatType,
                userId: userId,
                chatId: chatId,
                updateId: updateId
            )
        )
    }

    /// Sends a synthetic plain-text message update.
    func sendMessage(
        _ text: String,
        chatType: TGChatType = .private,
        userId: Int64 = 1,
        chatId: Int64 = 1,
        updateId: Int = 2
    ) async -> TelerouteBotTestResult {
        await self.execute(
            TelerouteTestSupport.makeMessageUpdate(
                text: text,
                chatType: chatType,
                userId: userId,
                chatId: chatId,
                updateId: updateId
            )
        )
    }

    /// Sends a synthetic callback-query update.
    func pressCallback(
        _ data: String,
        chatType: TGChatType = .private,
        callbackUserId: Int64 = 1,
        chatId: Int64 = 1,
        updateId: Int = 3
    ) async -> TelerouteBotTestResult {
        await self.execute(
            TelerouteTestSupport.makeCallbackUpdate(
                data: data,
                chatType: chatType,
                callbackUserId: callbackUserId,
                chatId: chatId,
                updateId: updateId
            )
        )
    }
}
