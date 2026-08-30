import Foundation
import HTTPTypes
import OpenAPIRuntime

/// Outbound request throttle applied by the default ``TelegramBotClient``
/// transport configuration.
public struct TelegramRateLimit: Sendable, Hashable {
    /// Sustained request rate.
    public var requestsPerSecond: Double
    /// Maximum burst allowed after an idle period.
    public var burst: Int

    public init(requestsPerSecond: Double, burst: Int? = nil) {
        precondition(requestsPerSecond > 0, "requestsPerSecond must be positive")
        self.requestsPerSecond = requestsPerSecond
        self.burst = burst ?? Int(requestsPerSecond.rounded(.up))
    }

    /// Telegram's documented overall bot limit of 30 requests per second.
    public static let `default` = TelegramRateLimit(requestsPerSecond: 30)
}

/// Token-bucket client middleware throttling every operation except
/// `getUpdates`, so long polling is never starved by outbound sends.
struct TelegramRateLimitMiddleware: ClientMiddleware {
    private let bucket: TelegramTokenBucket

    init(limit: TelegramRateLimit) {
        self.bucket = TelegramTokenBucket(
            ratePerSecond: limit.requestsPerSecond,
            capacity: Double(limit.burst)
        )
    }

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @concurrent @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        if operationID != "getUpdates" {
            try await self.bucket.acquire()
        }
        return try await next(request, body, baseURL)
    }
}

/// Continuously refilling token bucket.
final actor TelegramTokenBucket {
    private let ratePerSecond: Double
    private let capacity: Double
    private var tokens: Double
    private var lastRefill: ContinuousClock.Instant
    private let clock = ContinuousClock()

    init(ratePerSecond: Double, capacity: Double) {
        self.ratePerSecond = ratePerSecond
        self.capacity = max(capacity, 1)
        self.tokens = max(capacity, 1)
        self.lastRefill = self.clock.now
    }

    func acquire() async throws {
        while true {
            self.refill()
            if self.tokens >= 1 {
                self.tokens -= 1
                return
            }
            let secondsUntilNextToken = (1 - self.tokens) / self.ratePerSecond
            try await self.clock.sleep(for: .seconds(secondsUntilNextToken))
        }
    }

    private func refill() {
        let now = self.clock.now
        let elapsed = self.lastRefill.duration(to: now)
        let seconds = Double(elapsed.components.seconds)
            + Double(elapsed.components.attoseconds) / 1e18
        self.tokens = min(self.capacity, self.tokens + seconds * self.ratePerSecond)
        self.lastRefill = now
    }
}
