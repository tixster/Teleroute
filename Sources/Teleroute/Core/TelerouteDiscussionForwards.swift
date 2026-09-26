import Foundation
import OrderedCollections
import Synchronization

// MARK: - Policy

/// Whether a bot remembers channel posts that Telegram automatically forwards
/// into the channel's linked discussion chat, so callers can await them.
///
/// Observers registered with
/// ``TelerouteRouterGroup/onDiscussionForward(use:)`` work under either
/// policy; only ``TelerouteBot/discussionMessage(for:timeout:)`` and its
/// siblings need the buffer this policy keeps.
public enum TelerouteDiscussionForwardPolicy: Sendable {
    /// Awaiting discussion messages throws
    /// ``TelerouteDiscussionForwardError/trackingDisabled``.
    case disabled
    /// Automatic forwards are tracked in memory (the default).
    ///
    /// Tracking does not change `allowed_updates`: automatic forwards arrive
    /// as plain messages in the discussion chat, so the bot must already ask
    /// for `message` — any command or message route does. Awaiting logs a
    /// warning once when it does not.
    ///
    /// - Parameters:
    ///   - retention: How long a forward stays available to a caller that
    ///     starts waiting after it arrived — with webhooks the forward can
    ///     beat the `sendMessage` response.
    ///   - capacity: Maximum number of retained forwards; the oldest are
    ///     evicted first once it is reached.
    ///   - linkedChatCacheTTL: How long the result of looking up a channel's
    ///     linked chat (`getChat`) is reused, including a "no linked chat"
    ///     answer.
    case enabled(
        retention: Duration = .seconds(120),
        capacity: Int = 512,
        linkedChatCacheTTL: Duration = .seconds(600)
    )
}

// MARK: - Forward

/// A channel post that Telegram automatically forwarded into the channel's
/// linked discussion chat.
///
/// Replying to ``discussionMessageId`` in ``discussionChatId`` posts a
/// comment under the channel post.
public struct TelerouteDiscussionForward: Sendable, Hashable {
    /// Channel the post was published in.
    public let channelId: Int64
    /// Identifier of the post inside the channel.
    public let channelMessageId: Int64
    /// Discussion chat linked to the channel.
    public let discussionChatId: Int64
    /// The forwarded copy inside the discussion chat.
    public let message: Message

    /// Identifier of the forwarded copy inside the discussion chat.
    public var discussionMessageId: Int64 {
        self.message.messageId
    }

    /// Reads a discussion-chat message as an automatic forward. Returns `nil`
    /// for anything else, including a manual forward of a channel post.
    init?(_ message: Message) {
        guard message.isAutomaticForward == true,
              case let .channel(origin)? = message.forwardOrigin else {
            return nil
        }
        self.channelId = origin.chat.id
        self.channelMessageId = origin.messageId
        self.discussionChatId = message.chat.id
        self.message = message
    }
}

/// Thrown by `sendWithDiscussionForward` when the post was sent but its
/// discussion message could not be obtained.
///
/// The post is already published, so it travels with the error rather than
/// being lost; ``underlying`` says why waiting failed — usually a
/// ``TelerouteDiscussionForwardError``, a `CancellationError`, or the
/// `getChat` failure.
public struct TelerouteDiscussionPostError: Error, Sendable, CustomStringConvertible {
    /// The message that was sent.
    public let post: Message
    /// Why its discussion message could not be obtained.
    public let underlying: any Error

    public init(post: Message, underlying: any Error) {
        self.post = post
        self.underlying = underlying
    }

    public var description: String {
        "Message \(self.post.messageId) was sent to chat \(self.post.chat.id), but its discussion message could not be obtained: \(self.underlying)"
    }
}

/// Errors thrown while awaiting a channel post's discussion message.
public enum TelerouteDiscussionForwardError: Error, Sendable, Equatable, CustomStringConvertible {
    /// ``TelerouteConfiguration/discussionForwards`` is
    /// ``TelerouteDiscussionForwardPolicy/disabled``, or the context was not
    /// built by a running bot.
    case trackingDisabled
    /// The message passed as a post was not sent to a channel.
    case notAChannelPost(chatId: Int64)
    /// The automatic forward did not arrive in time.
    case timeout(channelId: Int64, channelMessageId: Int64, discussionChatId: Int64)
    /// The bot shut down while the caller was waiting.
    case shutdown

    public var description: String {
        switch self {
        case .trackingDisabled:
            "Discussion-forward tracking is disabled; set TelerouteConfiguration.discussionForwards to .enabled()."
        case let .notAChannelPost(chatId):
            "Message in chat \(chatId) is not a channel post."
        case let .timeout(channelId, channelMessageId, discussionChatId):
            "Post \(channelMessageId) of channel \(channelId) was not forwarded to discussion chat \(discussionChatId) in time."
        case .shutdown:
            "The bot shut down while waiting for a discussion message."
        }
    }
}

// MARK: - Observer

typealias TelerouteDiscussionForwardHandler = @Sendable (
    TelerouteDiscussionForward,
    TelerouteContext
) async throws -> Void

/// A hook notified of every automatic forward, independently of routing.
struct TelerouteDiscussionForwardObserver: Sendable {
    let handler: TelerouteDiscussionForwardHandler
}

// MARK: - Tracker

/// In-memory record of recent automatic forwards plus the callers waiting for
/// one.
///
/// Waiting is continuation-based: ``record(_:now:)`` resumes waiters the
/// moment a matching forward is seen. Recent forwards are retained too, so a
/// forward that arrives before the caller starts waiting is not lost.
final class TelerouteDiscussionForwardTracker: Sendable {
    struct Key: Hashable, Sendable {
        let channelId: Int64
        let channelMessageId: Int64
    }

    private struct Waiter {
        let discussionChatId: Int64
        let continuation: CheckedContinuation<TelerouteDiscussionForward, any Error>
    }

    private struct Recorded {
        let forward: TelerouteDiscussionForward
        let recordedAt: ContinuousClock.Instant
    }

    private struct LinkedChat {
        let chatId: Int64?
        let expiresAt: ContinuousClock.Instant
    }

    private struct State {
        /// Ordered by insertion, so eviction pops from the front.
        var recent: OrderedDictionary<Key, Recorded> = [:]
        var waiters: [Key: [UInt64: Waiter]] = [:]
        var linkedChats: [Int64: LinkedChat] = [:]
        var nextWaiterId: UInt64 = 0
        var isShutdown = false
    }

    private let state = Mutex(State())
    private let warnedAboutMissingMessages = Atomic(false)
    let retention: Duration
    let capacity: Int
    let linkedChatCacheTTL: Duration
    private let logger: Logger?
    /// Whether the bot asks Telegram for `message` updates, without which no
    /// automatic forward ever arrives.
    private let requestsMessages: @Sendable () -> Bool

    init(
        retention: Duration,
        capacity: Int,
        linkedChatCacheTTL: Duration,
        logger: Logger? = nil,
        requestsMessages: @escaping @Sendable () -> Bool = { true }
    ) {
        self.retention = retention
        self.capacity = max(1, capacity)
        self.linkedChatCacheTTL = linkedChatCacheTTL
        self.logger = logger
        self.requestsMessages = requestsMessages
    }

    convenience init?(
        _ policy: TelerouteDiscussionForwardPolicy,
        logger: Logger? = nil,
        requestsMessages: @escaping @Sendable () -> Bool = { true }
    ) {
        guard case let .enabled(retention, capacity, linkedChatCacheTTL) = policy else {
            return nil
        }
        self.init(
            retention: retention,
            capacity: capacity,
            linkedChatCacheTTL: linkedChatCacheTTL,
            logger: logger,
            requestsMessages: requestsMessages
        )
    }

    var count: Int {
        self.state.withLock { $0.recent.count }
    }

    var waiterCount: Int {
        self.state.withLock { $0.waiters.values.reduce(0) { $0 + $1.count } }
    }

    /// Retains a forward and resumes every caller waiting for it.
    func record(
        _ forward: TelerouteDiscussionForward,
        now: ContinuousClock.Instant = .now
    ) {
        let key = Key(channelId: forward.channelId, channelMessageId: forward.channelMessageId)
        let resumed = self.state.withLock { state -> [Waiter] in
            Self.removeExpired(from: &state, retention: self.retention, now: now)
            // Re-inserting moves a repeated forward to the back of the queue.
            state.recent.removeValue(forKey: key)
            state.recent[key] = Recorded(forward: forward, recordedAt: now)
            while state.recent.count > self.capacity {
                state.recent.removeFirst()
            }

            guard var waiters = state.waiters.removeValue(forKey: key) else { return [] }
            var matching: [Waiter] = []
            for (id, waiter) in waiters where waiter.discussionChatId == forward.discussionChatId {
                matching.append(waiter)
                waiters[id] = nil
            }
            if waiters.isEmpty == false {
                state.waiters[key] = waiters
            }
            return matching
        }
        for waiter in resumed {
            waiter.continuation.resume(returning: forward)
        }
    }

    /// Sends a post and waits for its discussion message. Checks that
    /// tracking is on before anything is sent; failures after the send carry
    /// the post in a ``TelerouteDiscussionPostError``.
    static func send(
        with tracker: TelerouteDiscussionForwardTracker?,
        bot: TelegramBotClient,
        timeout: Duration,
        _ send: (TelegramBotClient) async throws -> Message
    ) async throws -> (post: Message, forward: TelerouteDiscussionForward?) {
        guard let tracker else {
            throw TelerouteDiscussionForwardError.trackingDisabled
        }
        let post = try await send(bot)
        do {
            let forward = try await tracker.discussionMessage(for: post, timeout: timeout, bot: bot)
            return (post, forward)
        } catch {
            throw TelerouteDiscussionPostError(post: post, underlying: error)
        }
    }

    /// Waits for `post`, which must have been sent to a channel.
    func discussionMessage(
        for post: Message,
        timeout: Duration,
        bot: TelegramBotClient
    ) async throws -> TelerouteDiscussionForward? {
        guard post.chat.type == .channel else {
            throw TelerouteDiscussionForwardError.notAChannelPost(chatId: post.chat.id)
        }
        return try await self.discussionMessage(
            channelId: post.chat.id,
            messageId: post.messageId,
            timeout: timeout,
            bot: bot
        )
    }

    /// Waits for a channel post's automatic forward. Returns `nil` straight
    /// away when the channel has no linked discussion chat.
    func discussionMessage(
        channelId: Int64,
        messageId: Int64,
        timeout: Duration,
        bot: TelegramBotClient
    ) async throws -> TelerouteDiscussionForward? {
        self.warnIfMessagesAreNotRequested()
        guard let discussionChatId = try await self.linkedChatId(of: channelId, bot: bot) else {
            return nil
        }
        return try await self.wait(
            for: Key(channelId: channelId, channelMessageId: messageId),
            discussionChatId: discussionChatId,
            timeout: timeout
        )
    }

    /// Resumes every waiter with ``TelerouteDiscussionForwardError/shutdown``
    /// and rejects later waits.
    func shutdown() {
        let waiters = self.state.withLock { state -> [Waiter] in
            state.isShutdown = true
            let waiters = state.waiters.values.flatMap(\.values)
            state.waiters.removeAll()
            return waiters
        }
        for waiter in waiters {
            waiter.continuation.resume(throwing: TelerouteDiscussionForwardError.shutdown)
        }
    }

    /// Logs once when `allowed_updates` leaves out `message`: the wait would
    /// otherwise time out with nothing pointing at the cause.
    private func warnIfMessagesAreNotRequested() {
        guard let logger = self.logger,
              self.warnedAboutMissingMessages.load(ordering: .relaxed) == false,
              self.requestsMessages() == false,
              self.warnedAboutMissingMessages.exchange(true, ordering: .relaxed) == false else {
            return
        }
        logger.warning(
            "Waiting for a discussion message, but allowed_updates does not include message, so automatic forwards never arrive. Register a message route or an onDiscussionForward observer, or add .message to explicit allowed updates."
        )
    }

    // MARK: Linked chat

    private func linkedChatId(
        of channelId: Int64,
        bot: TelegramBotClient,
        now: ContinuousClock.Instant = .now
    ) async throws -> Int64? {
        let cached = self.state.withLock { state -> LinkedChat? in
            guard let linked = state.linkedChats[channelId], linked.expiresAt > now else {
                return nil
            }
            return linked
        }
        if let cached {
            return cached.chatId
        }

        // Concurrent misses may both ask Telegram; the answers are identical,
        // so the duplicate request is cheaper than coordinating them.
        let chatId = try await bot.getChat(chatId: .id(channelId)).linkedChatId
        let linked = LinkedChat(chatId: chatId, expiresAt: .now.advanced(by: self.linkedChatCacheTTL))
        self.state.withLock { $0.linkedChats[channelId] = linked }
        return chatId
    }

    // MARK: Waiting

    func wait(
        for key: Key,
        discussionChatId: Int64,
        timeout: Duration
    ) async throws -> TelerouteDiscussionForward {
        let id = self.state.withLock { state -> UInt64 in
            state.nextWaiterId &+= 1
            return state.nextWaiterId
        }
        return try await withThrowingTaskGroup(of: TelerouteDiscussionForward.self) { group in
            group.addTask {
                try await self.suspend(id: id, key: key, discussionChatId: discussionChatId)
            }
            group.addTask {
                try await Task.sleep(for: timeout)
                throw TelerouteDiscussionForwardError.timeout(
                    channelId: key.channelId,
                    channelMessageId: key.channelMessageId,
                    discussionChatId: discussionChatId
                )
            }
            defer { group.cancelAll() }
            guard let forward = try await group.next() else {
                throw CancellationError()
            }
            return forward
        }
    }

    private func suspend(
        id: UInt64,
        key: Key,
        discussionChatId: Int64
    ) async throws -> TelerouteDiscussionForward {
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let immediate = self.state.withLock { state -> Result<TelerouteDiscussionForward, any Error>? in
                    if state.isShutdown {
                        return .failure(TelerouteDiscussionForwardError.shutdown)
                    }
                    // Checked under the lock: a cancellation handler that ran
                    // before this registration found nothing to remove.
                    if Task.isCancelled {
                        return .failure(CancellationError())
                    }
                    Self.removeExpired(from: &state, retention: self.retention, now: .now)
                    if let recorded = state.recent[key],
                       recorded.forward.discussionChatId == discussionChatId {
                        return .success(recorded.forward)
                    }
                    state.waiters[key, default: [:]][id] = Waiter(
                        discussionChatId: discussionChatId,
                        continuation: continuation
                    )
                    return nil
                }
                if let immediate {
                    continuation.resume(with: immediate)
                }
            }
        } onCancel: {
            let waiter = self.state.withLock { state -> Waiter? in
                guard let waiter = state.waiters[key]?.removeValue(forKey: id) else { return nil }
                if state.waiters[key]?.isEmpty == true {
                    state.waiters[key] = nil
                }
                return waiter
            }
            waiter?.continuation.resume(throwing: CancellationError())
        }
    }

    private static func removeExpired(
        from state: inout State,
        retention: Duration,
        now: ContinuousClock.Instant
    ) {
        // Insertion-ordered, so the live entries are always a suffix.
        while let first = state.recent.elements.first,
              first.value.recordedAt.duration(to: now) > retention {
            state.recent.removeFirst()
        }
    }
}
