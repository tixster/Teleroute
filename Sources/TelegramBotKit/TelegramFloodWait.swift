import Foundation
import HTTPTypes
import TelegramBotAPI

/// Bounded automatic retry policy for flood-limited (HTTP 429) requests.
public struct TelegramFloodWaitPolicy: Sendable, Hashable {
    /// Maximum number of retries after the initial attempt.
    public var maxRetries: Int
    /// Upper bound on a single `retry_after` wait; longer waits surface the
    /// error instead of blocking the caller.
    public var maxWait: Duration

    public init(maxRetries: Int = 2, maxWait: Duration = .seconds(30)) {
        self.maxRetries = maxRetries
        self.maxWait = maxWait
    }

    public static let `default` = TelegramFloodWaitPolicy()
}

/// Client middleware that retries 429 responses after Telegram's
/// `retry_after` interval. Never applied to `getUpdates`, and only when the
/// request body is replayable.
struct TelegramFloodWaitRetryMiddleware: TelegramMiddleware {
    let policy: TelegramFloodWaitPolicy

    func intercept(
        _ request: HTTPRequest,
        body: Data?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, Data?, URL) async throws -> (HTTPResponse, Data)
    ) async throws -> (HTTPResponse, Data) {
        // Long polling is exempt: a 429 there is answered by backing off the
        // poll loop, not by replaying the same wait.
        guard operationID != "getUpdates" else {
            return try await next(request, body, baseURL)
        }

        var attempt = 0
        while true {
            let (response, responseBody) = try await next(request, body, baseURL)
            guard response.status.code == 429, attempt < self.policy.maxRetries else {
                return (response, responseBody)
            }
            guard let decoded = try? JSONDecoder().decode(
                TelegramErrorEnvelope.self, from: responseBody
            ),
                let seconds = decoded.parameters?.retryAfter,
                case let retryAfter = Duration.seconds(seconds),
                retryAfter <= self.policy.maxWait
            else {
                return (response, responseBody)
            }

            attempt += 1
            try await Task.sleep(for: retryAfter)
        }
    }
}
