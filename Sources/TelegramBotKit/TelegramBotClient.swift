import Foundation
import HTTPTypes
import TelegramBotAPI

/// Telegram Bot API client.
///
/// The typed convenience surface — one flat method per Bot API operation,
/// unwrapping Telegram's `{ok, result}` envelope — is generated into
/// `Generated/TelegramBotClient+*.swift` from the documentation snapshot in
/// `botapi/`. Anything Telegram ships before Teleroute regenerates is still
/// reachable through ``call(_:_:as:)``.
public struct TelegramBotClient: Sendable {
    /// `https://api.telegram.org/bot<token>`, or the same shape on a local Bot
    /// API server.
    let baseURL: URL
    let transport: any TelegramTransport
    let middlewares: [any TelegramMiddleware]
    /// Optional per-chat outbound pacing applied by the generated wrappers.
    let pacer: TelegramSendPacer?

    /// Telegram's default endpoint.
    public static let defaultServerURL = URL(string: "https://api.telegram.org")!

    /// Creates a client over an explicit transport.
    ///
    /// - Parameters:
    ///   - token: Bot token obtained from @BotFather.
    ///   - transport: Any ``TelegramTransport``.
    ///   - middlewares: Client middlewares applied to every request.
    ///   - serverURL: Bot API endpoint; override it to use a local Bot API server.
    ///   - sendPacing: Per-chat outbound message pacing; `nil` disables it.
    public init(
        token: String,
        transport: any TelegramTransport,
        middlewares: [any TelegramMiddleware] = [],
        serverURL: URL = TelegramBotClient.defaultServerURL,
        sendPacing: TelegramSendPacing? = nil
    ) throws {
        guard Self.isWellFormed(token: token) else {
            throw TelegramAPIError(
                operation: "init",
                statusCode: 0,
                errorDescription: "malformed bot token: expected <digits>:<secret>"
            )
        }
        self.baseURL = serverURL.appendingPathComponent("bot\(token)")
        self.transport = transport
        self.middlewares = middlewares
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
    ///   - serverURL: Bot API endpoint; override it to use a local Bot API server.
    ///   - sendPacing: Per-chat outbound message pacing; `nil` disables it.
    public init(
        token: String,
        rateLimit: TelegramRateLimit? = .default,
        floodWaitPolicy: TelegramFloodWaitPolicy? = .default,
        serverURL: URL = TelegramBotClient.defaultServerURL,
        sendPacing: TelegramSendPacing? = nil
    ) throws {
        let transport = AsyncHTTPClientTelegramTransport()
        var middlewares: [any TelegramMiddleware] = []
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
            serverURL: serverURL,
            sendPacing: sendPacing
        )
    }

    private static func isWellFormed(token: String) -> Bool {
        let parts = token.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty, !parts[1].isEmpty else { return false }
        return parts[0].allSatisfy(\.isNumber)
    }
}

// MARK: - Performing requests

extension TelegramBotClient {
    /// Sends a request and unwraps Telegram's `{ok, result}` envelope.
    public func perform<Result: Decodable & Sendable>(
        _ request: TelegramRequest,
        as _: Result.Type = Result.self
    ) async throws -> Result {
        let (data, statusCode) = try await self.transmit(request)
        let envelope: TelegramEnvelope<Result>
        do {
            envelope = try JSONDecoder().decode(TelegramEnvelope<Result>.self, from: data)
        } catch {
            throw TelegramAPIError.from(operation: request.operation, statusCode: statusCode, data: data)
        }
        guard envelope.ok, let result = envelope.result else {
            throw TelegramAPIError.from(operation: request.operation, statusCode: statusCode, data: data)
        }
        return result
    }

    /// Sends a request whose result is `Message` for a normal message and
    /// `true` for an inline one, surfacing the latter as `nil`.
    public func performMessageOrFlag(_ request: TelegramRequest) async throws -> Message? {
        try await self.perform(request, as: TelegramMessageOrFlag.self).message
    }

    /// Sends a request that only reports success.
    @discardableResult
    public func performFlag(_ request: TelegramRequest) async throws -> Bool {
        try await self.perform(request, as: Bool.self)
    }

    /// Calls a Bot API method that the generated surface does not cover yet.
    ///
    /// Useful when Telegram ships a method before Teleroute regenerates from the
    /// documentation.
    public func call<Result: Decodable & Sendable>(
        _ method: String,
        _ parameters: [String: any Encodable & Sendable] = [:],
        as _: Result.Type = Result.self
    ) async throws -> Result {
        var request = TelegramRequest(method)
        for name in parameters.keys.sorted() {
            request.setAny(name, parameters[name])
        }
        return try await self.perform(request)
    }

    private func transmit(_ request: TelegramRequest) async throws -> (Data, Int) {
        let encoded = try TelegramRequestEncoder.encode(request)
        var httpRequest = HTTPRequest(
            method: .post,
            scheme: nil,
            authority: nil,
            path: "/\(request.operation)"
        )
        httpRequest.headerFields[.contentType] = encoded.contentType

        let (response, data) = try await self.send(
            httpRequest,
            body: encoded.body,
            operationID: request.operation
        )
        return (data, response.status.code)
    }

    /// Runs the request through the middleware chain and out to the transport.
    ///
    /// The operation id is passed explicitly, which is what keeps
    /// ``TelegramRateLimitMiddleware`` able to exempt `getUpdates` from the
    /// outbound throttle.
    func send(
        _ request: HTTPRequest,
        body: Data?,
        operationID: String
    ) async throws -> (HTTPResponse, Data) {
        let transport = self.transport
        let middlewares = self.middlewares

        @Sendable
        func step(
            _ index: Int,
            _ request: HTTPRequest,
            _ body: Data?,
            _ baseURL: URL
        ) async throws -> (HTTPResponse, Data) {
            guard index < middlewares.count else {
                return try await transport.send(
                    request, body: body, baseURL: baseURL, operationID: operationID
                )
            }
            return try await middlewares[index].intercept(
                request,
                body: body,
                baseURL: baseURL,
                operationID: operationID,
                next: { request, body, baseURL in
                    try await step(index + 1, request, body, baseURL)
                }
            )
        }

        return try await step(0, request, body, self.baseURL)
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
}
