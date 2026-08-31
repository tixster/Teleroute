import Foundation
import HTTPTypes
import OpenAPIRuntime
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
struct TelegramFloodWaitRetryMiddleware: ClientMiddleware {
    private static let maximumErrorBodyBytes = 16 * 1024

    let policy: TelegramFloodWaitPolicy

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        guard operationID != "getUpdates",
              body == nil || body?.iterationBehavior == .multiple else {
            return try await next(request, body, baseURL)
        }

        var attempt = 0
        while true {
            let (response, responseBody) = try await next(request, body, baseURL)
            guard response.status.code == 429, attempt < self.policy.maxRetries else {
                return (response, responseBody)
            }

            var bufferedBody: HTTPBody?
            var retryAfter: Duration?
            if let responseBody {
                let data = try await Data(collecting: responseBody, upTo: Self.maximumErrorBodyBytes)
                bufferedBody = HTTPBody(data)
                if let decoded = try? JSONDecoder().decode(Components.Schemas._Error.self, from: data),
                   let seconds = decoded.parameters?.retryAfter {
                    retryAfter = .seconds(seconds)
                }
            }
            guard let retryAfter, retryAfter <= self.policy.maxWait else {
                return (response, bufferedBody)
            }

            attempt += 1
            try await Task.sleep(for: retryAfter)
        }
    }
}
