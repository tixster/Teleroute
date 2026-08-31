import Foundation
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime
import TelegramBotAPI

/// Telegram Bot API client.
///
/// The typed convenience surface — one flat method per Bot API operation,
/// unwrapping Telegram's `{ok, result}` envelope — is generated into
/// `Generated/TelegramBotClient+*.swift` by `Scripts/generate-client.py`.
/// The full raw OpenAPI surface stays reachable through ``api``.
public struct TelegramBotClient: Sendable {
    /// The complete generated Telegram Bot API surface.
    public let api: any APIProtocol
    /// Optional per-chat outbound pacing applied by the generated wrappers.
    let pacer: TelegramSendPacer?

    /// Creates a client over an explicit transport.
    ///
    /// - Parameters:
    ///   - token: Bot token obtained from @BotFather.
    ///   - transport: Any OpenAPI client transport.
    ///   - middlewares: Client middlewares applied to every request.
    ///   - sendPacing: Per-chat outbound message pacing; `nil` disables it.
    public init(
        token: String,
        transport: any ClientTransport,
        middlewares: [any ClientMiddleware] = [],
        sendPacing: TelegramSendPacing? = nil
    ) throws {
        self.api = Client(
            serverURL: try Servers.Server1.url(token: token),
            transport: transport,
            middlewares: middlewares
        )
        self.pacer = sendPacing.map(TelegramSendPacer.init)
    }

    /// Creates a client over AsyncHTTPClient with Telegram-friendly policies.
    ///
    /// The transport request timeout is raised above the long-polling wait so
    /// `getUpdates` calls are never cut short by the HTTP client.
    ///
    /// - Parameters:
    ///   - token: Bot token obtained from @BotFather.
    ///   - rateLimit: Global outbound throttle; pass `nil` to disable.
    ///   - floodWaitPolicy: Automatic bounded retry on 429 responses;
    ///     `nil` disables it and 429s surface as ``TelegramAPIError``.
    ///   - sendPacing: Per-chat outbound message pacing; `nil` disables it.
    public init(
        token: String,
        rateLimit: TelegramRateLimit? = .default,
        floodWaitPolicy: TelegramFloodWaitPolicy? = .default,
        sendPacing: TelegramSendPacing? = nil
    ) throws {
        let transport = AsyncHTTPClientTransport(
            configuration: .init(timeout: .seconds(70))
        )
        var middlewares: [any ClientMiddleware] = []
        if let rateLimit {
            middlewares.append(TelegramRateLimitMiddleware(limit: rateLimit))
        }
        if let floodWaitPolicy {
            middlewares.append(TelegramFloodWaitRetryMiddleware(policy: floodWaitPolicy))
        }
        try self.init(
            token: token,
            transport: transport,
            middlewares: middlewares,
            sendPacing: sendPacing
        )
    }

    /// Creates a client over a pre-built generated API implementation.
    /// Useful for tests that fake the whole `APIProtocol`.
    public init(api: any APIProtocol, sendPacing: TelegramSendPacing? = nil) {
        self.api = api
        self.pacer = sendPacing.map(TelegramSendPacer.init)
    }
}

// MARK: - Helpers used by the generated wrappers

extension TelegramBotClient {
    /// Waits on the per-chat pacer, when one is configured.
    @usableFromInline
    func pace(chatId: ChatId?) async throws {
        guard let pacer = self.pacer, let chatId else { return }
        try await pacer.acquire(chatId: chatId)
    }

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

    /// JSON-encodes a value into an HTTP body for a raw multipart part.
    /// Telegram expects array-valued fields as one JSON-serialized part.
    static func jsonBody(_ value: some Encodable) throws -> HTTPBody {
        HTTPBody(try JSONEncoder().encode(value))
    }
}
