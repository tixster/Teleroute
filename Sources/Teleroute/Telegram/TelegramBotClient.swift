import Foundation
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime
import TelegramBotAPI

/// Telegram Bot API client used by the routed bot.
///
/// Wraps the OpenAPI-generated client with the bot token, the default
/// transport, and typed convenience methods that unwrap Telegram's
/// `{ok, result}` response envelope. The full 185-operation surface stays
/// reachable through ``api``.
public struct TelegramBotClient: Sendable {
    /// The complete generated Telegram Bot API surface.
    public let api: any APIProtocol

    /// Creates a client over an explicit transport.
    ///
    /// - Parameters:
    ///   - token: Bot token obtained from @BotFather.
    ///   - transport: Any OpenAPI client transport.
    ///   - middlewares: Client middlewares applied to every request.
    public init(
        token: String,
        transport: any ClientTransport,
        middlewares: [any ClientMiddleware] = []
    ) throws {
        self.api = Client(
            serverURL: try Servers.Server1.url(token: token),
            transport: transport,
            middlewares: middlewares
        )
    }

    /// Creates a client over AsyncHTTPClient with an outbound rate limit.
    ///
    /// The transport request timeout is raised above the long-polling wait so
    /// `getUpdates` calls are never cut short by the HTTP client.
    ///
    /// - Parameters:
    ///   - token: Bot token obtained from @BotFather.
    ///   - rateLimit: Outbound throttle; pass `nil` to disable.
    public init(
        token: String,
        rateLimit: TelegramRateLimit? = .default
    ) throws {
        let transport = AsyncHTTPClientTransport(
            configuration: .init(timeout: .seconds(70))
        )
        var middlewares: [any ClientMiddleware] = []
        if let rateLimit {
            middlewares.append(TelegramRateLimitMiddleware(limit: rateLimit))
        }
        try self.init(token: token, transport: transport, middlewares: middlewares)
    }

    /// Creates a client over a pre-built generated API implementation.
    /// Useful for tests that fake the whole `APIProtocol`.
    public init(api: any APIProtocol) {
        self.api = api
    }
}

// MARK: - Bot info & updates

public extension TelegramBotClient {
    /// Basic information about the bot.
    func getMe() async throws -> User {
        switch try await self.api.getMe(.init()) {
        case let .ok(ok):
            return try ok.body.json.result
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "getMe", statusCode: statusCode, payload: payload
            )
        }
    }

    /// Receives incoming updates via long polling.
    func getUpdates(
        offset: Int64? = nil,
        limit: Int64? = nil,
        timeout: Int64? = nil,
        allowedUpdates: [String]? = nil
    ) async throws -> [Update] {
        let output = try await self.api.getUpdates(
            .init(query: .init(
                offset: offset,
                limit: limit,
                timeout: timeout,
                allowedUpdates: allowedUpdates
            ))
        )
        switch output {
        case let .ok(ok):
            return try ok.body.json.result
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "getUpdates", statusCode: statusCode, payload: payload
            )
        }
    }

    /// Removes a configured webhook so long polling can take over.
    @discardableResult
    func deleteWebhook(dropPendingUpdates: Bool? = nil) async throws -> Bool {
        let output = try await self.api.deleteWebhook(
            .init(body: .json(.init(dropPendingUpdates: dropPendingUpdates)))
        )
        switch output {
        case let .ok(ok):
            return try ok.body.json.result
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "deleteWebhook", statusCode: statusCode, payload: payload
            )
        }
    }
}

// MARK: - Messaging

public extension TelegramBotClient {
    /// Sends a text message.
    @discardableResult
    func sendMessage(
        chatId: ChatId,
        text: String,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        let output = try await self.api.sendMessage(
            .init(body: .json(.init(
                chatId: chatId,
                text: text,
                parseMode: parseMode?.rawValue,
                replyMarkup: replyMarkup
            )))
        )
        switch output {
        case let .ok(ok):
            return try ok.body.json.result
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "sendMessage", statusCode: statusCode, payload: payload
            )
        }
    }

    /// Edits the text of an existing message. Returns the edited message when
    /// Telegram provides one (inline-mode edits return only a confirmation).
    @discardableResult
    func editMessageText(
        chatId: ChatId,
        messageId: Int64,
        text: String,
        parseMode: ParseMode? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) async throws -> Message? {
        var parts: [Operations.EditMessageText.Input.Body.MultipartFormPayload] = [
            .chatId(.init(payload: .init(body: Self.body(for: chatId)))),
            .messageId(.init(payload: .init(body: HTTPBody(String(messageId))))),
            .text(.init(payload: .init(body: HTTPBody(text)))),
        ]
        if let parseMode {
            parts.append(.parseMode(.init(payload: .init(body: HTTPBody(parseMode.rawValue)))))
        }
        if let replyMarkup {
            parts.append(.replyMarkup(.init(payload: .init(body: replyMarkup))))
        }
        let output = try await self.api.editMessageText(
            .init(body: .multipartForm(.init(parts)))
        )
        switch output {
        case let .ok(ok):
            switch try ok.body.json.result {
            case let .Message(message): return message
            case .case2: return nil
            }
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "editMessageText", statusCode: statusCode, payload: payload
            )
        }
    }

    /// Replaces the inline keyboard of an existing message.
    @discardableResult
    func editMessageReplyMarkup(
        chatId: ChatId,
        messageId: Int64,
        replyMarkup: InlineKeyboardMarkup?
    ) async throws -> Message? {
        let output = try await self.api.editMessageReplyMarkup(
            .init(body: .json(.init(
                chatId: chatId,
                messageId: messageId,
                replyMarkup: replyMarkup
            )))
        )
        switch output {
        case let .ok(ok):
            switch try ok.body.json.result {
            case let .Message(message): return message
            case .case2: return nil
            }
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "editMessageReplyMarkup", statusCode: statusCode, payload: payload
            )
        }
    }

    /// Answers a callback query raised by an inline-keyboard button press.
    @discardableResult
    func answerCallbackQuery(
        callbackQueryId: String,
        text: String? = nil,
        showAlert: Bool? = nil,
        url: String? = nil,
        cacheTime: Int64? = nil
    ) async throws -> Bool {
        let output = try await self.api.answerCallbackQuery(
            .init(body: .json(.init(
                callbackQueryId: callbackQueryId,
                text: text,
                showAlert: showAlert,
                url: url,
                cacheTime: cacheTime
            )))
        )
        switch output {
        case let .ok(ok):
            return try ok.body.json.result
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "answerCallbackQuery", statusCode: statusCode, payload: payload
            )
        }
    }

    /// Forwards a message between chats.
    @discardableResult
    func forwardMessage(
        chatId: ChatId,
        fromChatId: ChatId,
        messageId: Int64
    ) async throws -> Message {
        let output = try await self.api.forwardMessage(
            .init(body: .json(.init(
                chatId: chatId,
                fromChatId: fromChatId,
                messageId: messageId
            )))
        )
        switch output {
        case let .ok(ok):
            return try ok.body.json.result
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "forwardMessage", statusCode: statusCode, payload: payload
            )
        }
    }

    /// Deletes a message.
    @discardableResult
    func deleteMessage(chatId: ChatId, messageId: Int64) async throws -> Bool {
        let output = try await self.api.deleteMessage(
            .init(body: .json(.init(chatId: chatId, messageId: messageId)))
        )
        switch output {
        case let .ok(ok):
            return try ok.body.json.result
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "deleteMessage", statusCode: statusCode, payload: payload
            )
        }
    }

    /// Shows a chat action such as "typing…".
    @discardableResult
    func sendChatAction(_ action: ChatAction, chatId: ChatId) async throws -> Bool {
        let output = try await self.api.sendChatAction(
            .init(body: .json(.init(chatId: chatId, action: action.rawValue)))
        )
        switch output {
        case let .ok(ok):
            return try ok.body.json.result
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "sendChatAction", statusCode: statusCode, payload: payload
            )
        }
    }
}

// MARK: - Chat & command management

public extension TelegramBotClient {
    /// Information about a member of a chat.
    func getChatMember(chatId: ChatId, userId: Int64) async throws -> ChatMember {
        let output = try await self.api.getChatMember(
            .init(query: .init(chatId: chatId, userId: userId))
        )
        switch output {
        case let .ok(ok):
            return try ok.body.json.result
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "getChatMember", statusCode: statusCode, payload: payload
            )
        }
    }

    /// Publishes the bot's command list for one scope.
    @discardableResult
    func setMyCommands(
        _ commands: [BotCommand],
        scope: BotCommandScope? = nil,
        languageCode: String? = nil
    ) async throws -> Bool {
        let output = try await self.api.setMyCommands(
            .init(body: .json(.init(
                commands: commands,
                scope: scope,
                languageCode: languageCode
            )))
        )
        switch output {
        case let .ok(ok):
            return try ok.body.json.result
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "setMyCommands", statusCode: statusCode, payload: payload
            )
        }
    }

    /// Clears the bot's command list for one scope.
    @discardableResult
    func deleteMyCommands(
        scope: BotCommandScope? = nil,
        languageCode: String? = nil
    ) async throws -> Bool {
        let output = try await self.api.deleteMyCommands(
            .init(body: .json(.init(scope: scope, languageCode: languageCode)))
        )
        switch output {
        case let .ok(ok):
            return try ok.body.json.result
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "deleteMyCommands", statusCode: statusCode, payload: payload
            )
        }
    }
}

// MARK: - Media

public extension TelegramBotClient {
    /// Sends a photo.
    @discardableResult
    func sendPhoto(
        _ photo: FileInput,
        chatId: ChatId,
        caption: String? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        typealias Part = Operations.SendPhoto.Input.Body.MultipartFormPayload
        var parts: [Part] = [
            .chatId(.init(payload: .init(body: Self.body(for: chatId)))),
            .photo(Self.filePart(photo) { .init(body: $0) }),
        ]
        if let caption { parts.append(.caption(.init(payload: .init(body: HTTPBody(caption))))) }
        if let parseMode { parts.append(.parseMode(.init(payload: .init(body: HTTPBody(parseMode.rawValue))))) }
        if let replyMarkup { parts.append(.replyMarkup(.init(payload: .init(body: replyMarkup)))) }
        let output = try await self.api.sendPhoto(.init(body: .multipartForm(.init(parts))))
        switch output {
        case let .ok(ok):
            return try ok.body.json.result
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "sendPhoto", statusCode: statusCode, payload: payload
            )
        }
    }

    /// Sends a general file.
    @discardableResult
    func sendDocument(
        _ document: FileInput,
        chatId: ChatId,
        caption: String? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        typealias Part = Operations.SendDocument.Input.Body.MultipartFormPayload
        var parts: [Part] = [
            .chatId(.init(payload: .init(body: Self.body(for: chatId)))),
            .document(Self.filePart(document) { .init(body: $0) }),
        ]
        if let caption { parts.append(.caption(.init(payload: .init(body: HTTPBody(caption))))) }
        if let parseMode { parts.append(.parseMode(.init(payload: .init(body: HTTPBody(parseMode.rawValue))))) }
        if let replyMarkup { parts.append(.replyMarkup(.init(payload: .init(body: replyMarkup)))) }
        let output = try await self.api.sendDocument(.init(body: .multipartForm(.init(parts))))
        switch output {
        case let .ok(ok):
            return try ok.body.json.result
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "sendDocument", statusCode: statusCode, payload: payload
            )
        }
    }

    /// Sends a video.
    @discardableResult
    func sendVideo(
        _ video: FileInput,
        chatId: ChatId,
        caption: String? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        typealias Part = Operations.SendVideo.Input.Body.MultipartFormPayload
        var parts: [Part] = [
            .chatId(.init(payload: .init(body: Self.body(for: chatId)))),
            .video(Self.filePart(video) { .init(body: $0) }),
        ]
        if let caption { parts.append(.caption(.init(payload: .init(body: HTTPBody(caption))))) }
        if let parseMode { parts.append(.parseMode(.init(payload: .init(body: HTTPBody(parseMode.rawValue))))) }
        if let replyMarkup { parts.append(.replyMarkup(.init(payload: .init(body: replyMarkup)))) }
        let output = try await self.api.sendVideo(.init(body: .multipartForm(.init(parts))))
        switch output {
        case let .ok(ok):
            return try ok.body.json.result
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "sendVideo", statusCode: statusCode, payload: payload
            )
        }
    }

    /// Sends an animation (GIF or short soundless video).
    @discardableResult
    func sendAnimation(
        _ animation: FileInput,
        chatId: ChatId,
        caption: String? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        typealias Part = Operations.SendAnimation.Input.Body.MultipartFormPayload
        var parts: [Part] = [
            .chatId(.init(payload: .init(body: Self.body(for: chatId)))),
            .animation(Self.filePart(animation) { .init(body: $0) }),
        ]
        if let caption { parts.append(.caption(.init(payload: .init(body: HTTPBody(caption))))) }
        if let parseMode { parts.append(.parseMode(.init(payload: .init(body: HTTPBody(parseMode.rawValue))))) }
        if let replyMarkup { parts.append(.replyMarkup(.init(payload: .init(body: replyMarkup)))) }
        let output = try await self.api.sendAnimation(.init(body: .multipartForm(.init(parts))))
        switch output {
        case let .ok(ok):
            return try ok.body.json.result
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "sendAnimation", statusCode: statusCode, payload: payload
            )
        }
    }

    /// Sends an audio file.
    @discardableResult
    func sendAudio(
        _ audio: FileInput,
        chatId: ChatId,
        caption: String? = nil,
        parseMode: ParseMode? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        typealias Part = Operations.SendAudio.Input.Body.MultipartFormPayload
        var parts: [Part] = [
            .chatId(.init(payload: .init(body: Self.body(for: chatId)))),
            .audio(Self.filePart(audio) { .init(body: $0) }),
        ]
        if let caption { parts.append(.caption(.init(payload: .init(body: HTTPBody(caption))))) }
        if let parseMode { parts.append(.parseMode(.init(payload: .init(body: HTTPBody(parseMode.rawValue))))) }
        if let replyMarkup { parts.append(.replyMarkup(.init(payload: .init(body: replyMarkup)))) }
        let output = try await self.api.sendAudio(.init(body: .multipartForm(.init(parts))))
        switch output {
        case let .ok(ok):
            return try ok.body.json.result
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "sendAudio", statusCode: statusCode, payload: payload
            )
        }
    }

    /// Sends a group of photos, videos, documents, or audios as an album.
    ///
    /// Media must reference existing `file_id` values or HTTP URLs; Telegram
    /// expects the `media` field as one JSON-encoded array.
    @discardableResult
    func sendMediaGroup(
        _ media: [InputMedia],
        chatId: ChatId
    ) async throws -> [Message] {
        typealias Part = Operations.SendMediaGroup.Input.Body.MultipartFormPayload
        let encodedMedia = try JSONEncoder().encode(media)
        let parts: [Part] = [
            .chatId(.init(payload: .init(body: Self.body(for: chatId)))),
            .additionalProperties(.init(payload: HTTPBody(encodedMedia), name: "media")),
        ]
        let output = try await self.api.sendMediaGroup(.init(body: .multipartForm(.init(parts))))
        switch output {
        case let .ok(ok):
            return try ok.body.json.result
        case let .undocumented(statusCode, payload):
            throw await TelegramAPIError.undocumented(
                operation: "sendMediaGroup", statusCode: statusCode, payload: payload
            )
        }
    }
}

// MARK: - Multipart helpers

extension TelegramBotClient {
    static func body(for chatId: ChatId) -> HTTPBody {
        switch chatId {
        case let .case1(id): HTTPBody(String(id))
        case let .case2(username): HTTPBody(username)
        }
    }

    /// Builds a raw file part from a ``FileInput``: `file_id`/URL values go as
    /// text, uploads as binary bodies with a filename.
    static func filePart<Payload>(
        _ file: FileInput,
        _ makePayload: (HTTPBody) -> Payload
    ) -> OpenAPIRuntime.MultipartPart<Payload> {
        switch file {
        case let .fileID(value), let .url(value):
            .init(payload: makePayload(HTTPBody(value)))
        case let .upload(filename, data):
            .init(payload: makePayload(HTTPBody(data)), filename: filename)
        }
    }
}
