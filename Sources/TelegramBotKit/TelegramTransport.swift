import Foundation
import HTTPTypes

/// Carries one Bot API request to Telegram and brings the response back.
///
/// Bodies are `Data` rather than a byte stream, because every request this
/// client builds is already a complete buffer and every response it needs is
/// decoded whole. That makes the protocol a single method, and it makes every
/// request trivially replayable — which is what lets
/// ``TelegramFloodWaitRetryMiddleware`` retry without asking whether the body
/// can be read twice.
///
/// Fakes conform to this for tests; `TelerouteTestSupport` ships two.
public protocol TelegramTransport: Sendable {
    /// - Parameters:
    ///   - request: Method and path, relative to `baseURL`.
    ///   - body: The encoded request body, or `nil` for a bodiless call.
    ///   - baseURL: `https://api.telegram.org/bot<token>`, or a local server.
    ///   - operationID: The Bot API method name, e.g. `sendMessage`.
    func send(
        _ request: HTTPRequest,
        body: Data?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, Data)
}

/// Wraps every request on its way out and every response on its way back.
///
/// `operationID` is the Bot API method name, which is how
/// ``TelegramRateLimitMiddleware`` exempts `getUpdates` from the outbound
/// throttle.
public protocol TelegramMiddleware: Sendable {
    func intercept(
        _ request: HTTPRequest,
        body: Data?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, Data?, URL) async throws -> (HTTPResponse, Data)
    ) async throws -> (HTTPResponse, Data)
}
