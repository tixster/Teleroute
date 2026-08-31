import Foundation
import Logging

/// Which update kinds the bot asks Telegram to deliver.
public enum TelerouteAllowedUpdates: Sendable {
    /// Derives the set from the registered routes: message routes, commands,
    /// callbacks, flows, and `on(_:)`/typed update handlers. Registering an
    /// `unmatched` hook widens this to every kind.
    case automatic
    /// Requests every update kind.
    case all
    /// Requests exactly the supplied kinds.
    case explicit([UpdateKind])
}

/// Long-polling behavior of a routed bot.
public struct TelegramPollingConfiguration: Sendable {
    /// Maximum updates per `getUpdates` call (1–100, Telegram default 100).
    public var limit: Int64?
    /// Long-polling wait in seconds.
    public var timeout: Int64
    /// Update kinds to receive.
    public var allowedUpdates: TelerouteAllowedUpdates
    /// Removes a configured webhook before polling starts, since Telegram
    /// rejects `getUpdates` while a webhook is active.
    public var deleteWebhookOnStart: Bool
    /// Initial delay before retrying after a polling failure.
    public var initialBackoff: Duration
    /// Upper bound for the exponential retry delay.
    public var maximumBackoff: Duration

    public init(
        limit: Int64? = nil,
        timeout: Int64 = 10,
        allowedUpdates: TelerouteAllowedUpdates = .automatic,
        deleteWebhookOnStart: Bool = true,
        initialBackoff: Duration = .seconds(1),
        maximumBackoff: Duration = .seconds(30)
    ) {
        self.limit = limit
        self.timeout = timeout
        self.allowedUpdates = allowedUpdates
        self.deleteWebhookOnStart = deleteWebhookOnStart
        self.initialBackoff = initialBackoff
        self.maximumBackoff = maximumBackoff
    }
}

/// Owns the `getUpdates` loop: offset tracking, error backoff, and clean
/// cancellation. Feeds each received batch to the supplied consumer.
struct TelegramLongPollingConnection: Sendable {
    let client: TelegramBotClient
    let configuration: TelegramPollingConfiguration
    /// Wire strings resolved from ``TelegramPollingConfiguration/allowedUpdates``.
    let resolvedAllowedUpdates: [String]?
    let logger: Logger

    /// Polls until the surrounding task is cancelled. Errors never abort the
    /// loop; they are logged and retried with jittered exponential backoff.
    func run(
        onUpdates: @Sendable ([Update]) async -> Void
    ) async {
        if self.configuration.deleteWebhookOnStart {
            await self.deleteWebhook()
        }

        var offset: Int64?
        var backoff = self.configuration.initialBackoff

        while Task.isCancelled == false {
            do {
                let updates = try await self.client.getUpdates(
                    offset: offset,
                    limit: self.configuration.limit,
                    timeout: self.configuration.timeout,
                    allowedUpdates: self.resolvedAllowedUpdates
                )
                backoff = self.configuration.initialBackoff
                if let lastId = updates.last?.updateId {
                    offset = lastId + 1
                }
                if updates.isEmpty == false {
                    await onUpdates(updates)
                }
            } catch is CancellationError {
                return
            } catch {
                guard Task.isCancelled == false else { return }
                self.logger.error(
                    "Telegram long polling failed; retrying",
                    metadata: [
                        "error": .string(String(reflecting: error)),
                        "backoff": .stringConvertible(backoff),
                    ]
                )
                do {
                    try await Task.sleep(for: Self.jittered(backoff))
                } catch {
                    return
                }
                backoff = min(backoff * 2, self.configuration.maximumBackoff)
            }
        }
    }

    private func deleteWebhook() async {
        do {
            try await self.client.deleteWebhook()
        } catch is CancellationError {
            return
        } catch {
            self.logger.warning(
                "Failed to delete webhook before long polling",
                metadata: ["error": .string(String(reflecting: error))]
            )
        }
    }

    /// Full jitter: a uniformly random delay in `(0, backoff]`.
    private static func jittered(_ backoff: Duration) -> Duration {
        backoff * Double.random(in: 0.1...1.0)
    }
}
