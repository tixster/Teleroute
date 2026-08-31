import Foundation

/// Per-chat outbound pacing configuration.
///
/// Telegram enforces roughly one message per second per chat and twenty
/// messages per minute per group; exceeding them yields 429 responses.
public struct TelegramSendPacing: Sendable, Hashable {
    /// Minimum interval between messages to one private chat.
    public var perChatInterval: Duration
    /// Minimum interval between messages to one group or channel
    /// (chats with negative identifiers, or `@username` targets).
    public var perGroupInterval: Duration

    public init(
        perChatInterval: Duration = .seconds(1),
        perGroupInterval: Duration = .seconds(3)
    ) {
        self.perChatInterval = perChatInterval
        self.perGroupInterval = perGroupInterval
    }

    /// Pacing matching Telegram's documented limits
    /// (1 msg/s per chat, 20 msg/min per group).
    public static let telegramDefaults = TelegramSendPacing()
}

/// Serializes outbound sends per chat so the bot never exceeds Telegram's
/// per-chat rate limits. Invoked by the generated client wrappers for every
/// operation that carries a `chat_id`.
final actor TelegramSendPacer {
    private let pacing: TelegramSendPacing
    private let clock = ContinuousClock()
    private var nextAllowed: [String: ContinuousClock.Instant] = [:]

    init(pacing: TelegramSendPacing) {
        self.pacing = pacing
    }

    func acquire(chatId: ChatId) async throws {
        let (key, interval) = self.slot(for: chatId)
        let now = self.clock.now
        let scheduled = max(self.nextAllowed[key] ?? now, now)
        self.nextAllowed[key] = scheduled + interval
        self.pruneIfNeeded(now: now)
        if scheduled > now {
            try await self.clock.sleep(until: scheduled)
        }
    }

    private func slot(for chatId: ChatId) -> (key: String, interval: Duration) {
        switch chatId {
        case let .case1(id):
            (String(id), id < 0 ? self.pacing.perGroupInterval : self.pacing.perChatInterval)
        case let .case2(username):
            (username, self.pacing.perGroupInterval)
        }
    }

    private func pruneIfNeeded(now: ContinuousClock.Instant) {
        guard self.nextAllowed.count > 1024 else { return }
        self.nextAllowed = self.nextAllowed.filter { $0.value > now }
    }
}
