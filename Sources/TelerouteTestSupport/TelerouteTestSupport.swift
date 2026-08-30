import Foundation
import HTTPTypes
import OpenAPIRuntime
import Synchronization
import Teleroute

/// Test doubles and helpers for users (and the Teleroute test suite) to exercise
/// routes, middleware, and flows without a live Telegram connection.
///
/// Add `TelerouteTestSupport` to your test target dependencies, then use
/// ``TelerouteTestSupport/makeTelerouteBot(router:configuration:label:)`` for a
/// complete in-process routed bot or ``TelerouteTestSupport/makeClient(transport:)``
/// with your own `ClientTransport` fake.

/// A no-op `ClientTransport` that throws on every network call.
///
/// Use it for routing/middleware tests that never reach the Telegram API. For
/// tests that must observe outgoing API calls, use
/// ``TelerouteRecordingTransport`` instead.
public struct TelerouteStubTransport: ClientTransport {
    public init() {}

    public func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        throw TelerouteTestNetworkError.unexpectedCall
    }
}

/// Errors thrown by the built-in test doubles.
public enum TelerouteTestNetworkError: Error, Equatable, Sendable {
    /// Raised by ``TelerouteStubTransport`` on any API call.
    case unexpectedCall
    /// Raised when the recording transport does not know how to fake a
    /// Telegram method's response.
    case unsupportedMethod(String)
    /// Raised when a request body cannot be decoded by the recording transport.
    case malformedRequest(String)
}

/// Text message sent by a route during an in-process test.
public struct TelerouteRecordedMessage: Sendable {
    public let chatId: ChatId
    public let text: String
    public let replyMarkup: ReplyMarkup?
}

/// Message edit performed by a route during an in-process test.
public struct TelerouteRecordedEdit: Sendable {
    public let chatId: ChatId?
    public let messageId: Int64?
    public let text: String
    public let replyMarkup: InlineKeyboardMarkup?
}

/// Callback-query answer performed during an in-process test.
public struct TelerouteRecordedCallbackAnswer: Sendable {
    public let callbackQueryId: String
    public let text: String?
    public let showAlert: Bool?
}

/// Telegram side effect captured by ``TelerouteRecordingTransport``.
public enum TelerouteRecordedEffect: Sendable {
    case sentMessage(TelerouteRecordedMessage)
    case editedMessage(TelerouteRecordedEdit)
    case answeredCallback(TelerouteRecordedCallbackAnswer)
    case commandMenuUpdated
}

/// In-memory Telegram transport that records common text, keyboard, callback,
/// and command-menu operations while returning synthetic successful responses.
///
/// Dispatches on the OpenAPI operation id, so it works with any client built
/// over the generated Telegram Bot API.
public final class TelerouteRecordingTransport: ClientTransport, Sendable {
    private struct State: Sendable {
        var effects: [TelerouteRecordedEffect] = []
        var nextMessageId: Int64 = 1
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

    public func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let data: Data
        if let body {
            data = try await Data(collecting: body, upTo: 10 * 1024 * 1024)
        } else {
            data = Data()
        }

        switch operationID {
        case "sendMessage":
            let value = try Self.decode(RecordedSendMessageParams.self, from: data)
            let message = self.state.withLock { state -> Message in
                state.effects.append(
                    .sentMessage(
                        .init(
                            chatId: value.chatId,
                            text: value.text,
                            replyMarkup: value.replyMarkup
                        )
                    )
                )
                defer { state.nextMessageId += 1 }
                return Self.makeMessage(
                    messageId: state.nextMessageId,
                    chatId: value.chatId,
                    text: value.text
                )
            }
            return try Self.okResponse(result: message)

        case "editMessageText":
            let fields = try Self.multipartFields(from: data, request: request)
            guard let text = fields["text"].map({ String(decoding: $0, as: UTF8.self) }) else {
                throw TelerouteTestNetworkError.malformedRequest(operationID)
            }
            let chatId = fields["chat_id"]
                .map { String(decoding: $0, as: UTF8.self) }
                .map { raw in Int64(raw).map(ChatId.id) ?? .username(raw) }
            let messageId = fields["message_id"]
                .flatMap { Int64(String(decoding: $0, as: UTF8.self)) }
            let replyMarkup = try fields["reply_markup"]
                .map { try JSONDecoder().decode(InlineKeyboardMarkup.self, from: $0) }
            self.state.withLock {
                $0.effects.append(
                    .editedMessage(
                        .init(
                            chatId: chatId,
                            messageId: messageId,
                            text: text,
                            replyMarkup: replyMarkup
                        )
                    )
                )
            }
            return try Self.okResponse(result: true)

        case "answerCallbackQuery":
            let value = try Self.decode(RecordedAnswerCallbackParams.self, from: data)
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
            return try Self.okResponse(result: true)

        case "setMyCommands", "deleteMyCommands":
            self.state.withLock { $0.effects.append(.commandMenuUpdated) }
            return try Self.okResponse(result: true)

        case "deleteWebhook":
            return try Self.okResponse(result: true)

        case "getUpdates":
            // Simulate a quiet long poll so a started bot does not spin.
            try await Task.sleep(for: .seconds(1))
            return try Self.okResponse(result: [Update]())

        default:
            throw TelerouteTestNetworkError.unsupportedMethod(operationID)
        }
    }

    private static func decode<Value: Decodable>(
        _ type: Value.Type,
        from data: Data
    ) throws -> Value {
        try JSONDecoder().decode(type, from: data)
    }

    private static func okResponse(result: some Encodable) throws -> (HTTPResponse, HTTPBody?) {
        let envelope = try JSONEncoder().encode(OkEnvelope(ok: true, result: result))
        var response = HTTPResponse(status: .ok)
        response.headerFields[.contentType] = "application/json; charset=utf-8"
        return (response, HTTPBody(envelope))
    }

    private static func makeMessage(
        messageId: Int64,
        chatId: ChatId,
        text: String
    ) -> Message {
        Message(
            messageId: messageId,
            from: User(id: 0, isBot: true, firstName: "Teleroute"),
            date: 1,
            chat: Chat(id: chatId.int64Value ?? 0, _type: ChatType.private.rawValue),
            text: text
        )
    }

    /// Minimal `multipart/form-data` parser sufficient for the text parts the
    /// Telegram client sends. Returns part bodies keyed by field name.
    private static func multipartFields(
        from data: Data,
        request: HTTPRequest
    ) throws -> [String: Data] {
        guard let contentType = request.headerFields[.contentType],
              let boundaryRange = contentType.range(of: "boundary=") else {
            throw TelerouteTestNetworkError.malformedRequest("missing multipart boundary")
        }
        var boundary = String(contentType[boundaryRange.upperBound...])
        if let semicolon = boundary.firstIndex(of: ";") {
            boundary = String(boundary[..<semicolon])
        }
        boundary = boundary.trimmingCharacters(in: .init(charactersIn: "\" "))

        let delimiter = Data("--\(boundary)".utf8)
        let headerSeparator = Data("\r\n\r\n".utf8)
        var fields: [String: Data] = [:]

        var searchStart = data.startIndex
        while let delimiterRange = data.range(of: delimiter, in: searchStart..<data.endIndex) {
            let partStart = delimiterRange.upperBound
            guard let nextDelimiter = data.range(of: delimiter, in: partStart..<data.endIndex) else {
                break
            }
            let part = data[partStart..<nextDelimiter.lowerBound]
            searchStart = nextDelimiter.lowerBound

            guard let headerEnd = part.range(of: headerSeparator) else { continue }
            let headerText = String(decoding: part[part.startIndex..<headerEnd.lowerBound], as: UTF8.self)
            guard let nameRange = headerText.range(of: "name=\"") else { continue }
            guard let nameEnd = headerText[nameRange.upperBound...].firstIndex(of: "\"") else { continue }
            let name = String(headerText[nameRange.upperBound..<nameEnd])

            var body = part[headerEnd.upperBound...]
            if body.suffix(2).elementsEqual(Data("\r\n".utf8)) {
                body = body.dropLast(2)
            }
            fields[name] = Data(body)
        }
        return fields
    }
}

private struct OkEnvelope<Result: Encodable>: Encodable {
    let ok: Bool
    let result: Result
}

private struct RecordedSendMessageParams: Decodable {
    let chatId: ChatId
    let text: String
    let replyMarkup: ReplyMarkup?

    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
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

/// Builds Telegram clients and routed bots suitable for tests. Nothing here
/// performs network calls unless the supplied transport does.
public enum TelerouteTestSupport {
    /// Token used by all test clients; never sent anywhere by the fakes.
    public static let testToken = "123456:test-token"

    /// Creates a Telegram client backed by the supplied transport
    /// (defaults to ``TelerouteStubTransport``).
    public static func makeClient(
        transport: any ClientTransport = TelerouteStubTransport()
    ) throws -> TelegramBotClient {
        try TelegramBotClient(token: self.testToken, transport: transport)
    }

    /// Creates a routed bot and recording Telegram transport for in-process tests.
    public static func makeTelerouteBot<Context: TelerouteRequestContext>(
        router: Teleroute<Context>,
        configuration: TelerouteBot.Configuration = .init(
            replayProtectionStorage: nil
        ),
        label: String = "teleroute.tests.bot"
    ) throws -> (
        bot: TelerouteBot,
        telegram: TelerouteRecordingTransport
    ) {
        let telegram = TelerouteRecordingTransport()
        let bot = try TelerouteBot(
            token: self.testToken,
            router: router,
            logger: .init(label: label),
            configuration: configuration,
            transport: telegram,
            rateLimit: nil
        )
        return (bot, telegram)
    }

    /// Builds a synthetic command update (`/name args`).
    public static func makeCommandUpdate(
        text: String,
        chatType: ChatType = .private,
        userId: Int64 = 1,
        chatId: Int64 = 1,
        updateId: Int64 = 1
    ) -> Update {
        let commandToken = String(text.split(maxSplits: 1, whereSeparator: \.isWhitespace).first ?? "")
        let entity = MessageEntity.botCommand(offset: 0, length: Int64(commandToken.utf16.count))
        let message = Message(
            messageId: 1,
            from: User(id: userId, isBot: false, firstName: "Test", username: "tester"),
            date: 1,
            chat: Chat(id: chatId, _type: chatType.rawValue, firstName: "Test"),
            text: text,
            entities: [entity]
        )
        return Update(updateId: updateId, message: message)
    }

    /// Builds a synthetic plain-text message update.
    public static func makeMessageUpdate(
        text: String,
        chatType: ChatType = .private,
        userId: Int64 = 1,
        chatId: Int64 = 1,
        updateId: Int64 = 2
    ) -> Update {
        let message = Message(
            messageId: 2,
            from: User(id: userId, isBot: false, firstName: "Test", username: "tester"),
            date: 1,
            chat: Chat(id: chatId, _type: chatType.rawValue, firstName: "Test"),
            text: text
        )
        return Update(updateId: updateId, message: message)
    }

    /// Builds a synthetic callback-query update for inline-button presses.
    public static func makeCallbackUpdate(
        data: String,
        chatType: ChatType = .private,
        messageUserId: Int64 = 1,
        messageIsBot: Bool = false,
        callbackUserId: Int64 = 1,
        chatId: Int64 = 1,
        updateId: Int64 = 3
    ) -> Update {
        let message = Message(
            messageId: 1,
            from: User(id: messageUserId, isBot: messageIsBot, firstName: "Test", username: "tester"),
            date: 1,
            chat: Chat(id: chatId, _type: chatType.rawValue, firstName: "Test"),
            text: "callback host"
        )
        let callbackQuery = CallbackQuery(
            id: "callback-id",
            from: User(id: callbackUserId, isBot: false, firstName: "Test", username: "tester"),
            message: .Message(message),
            chatInstance: "chat-instance",
            data: data
        )
        return Update(updateId: updateId, callbackQuery: callbackQuery)
    }
}

public extension TelerouteBotTestClient {
    /// Sends a synthetic `/command arguments` update.
    func sendCommand(
        _ text: String,
        chatType: ChatType = .private,
        userId: Int64 = 1,
        chatId: Int64 = 1,
        updateId: Int64 = 1
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
        chatType: ChatType = .private,
        userId: Int64 = 1,
        chatId: Int64 = 1,
        updateId: Int64 = 2
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
        chatType: ChatType = .private,
        callbackUserId: Int64 = 1,
        chatId: Int64 = 1,
        updateId: Int64 = 3
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
