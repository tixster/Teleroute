import Foundation
import OrderedCollections
import Synchronization

// MARK: - Policy

/// Who may press a button that carries an inline handler.
public enum TelerouteInlineActionScope: Sendable, Hashable {
    /// Only the user the keyboard was rendered for. The default: in a group
    /// chat any member can press any button, and without this the handler
    /// would run for the wrong person.
    case user
    /// Any member of the chat the keyboard was rendered in.
    case chat
    /// Anyone who can reach the message.
    case anyone
}

/// What happens to a button once its handler has run without throwing.
public enum TelerouteButtonCompletion: Sendable, Hashable {
    /// Leave the keyboard alone (the default).
    case keep
    /// Remove just this button. An emptied row is dropped, and an emptied
    /// keyboard is removed entirely.
    case removeButton
    /// Remove the whole keyboard.
    case removeKeyboard
}

/// Whether buttons may carry inline handlers, and how long those handlers live.
///
/// Handlers are closures, so they cannot be serialized: they live in the
/// process that rendered them. See <doc:Keyboards> for what that rules out.
public enum TelerouteInlineActionPolicy: Sendable {
    /// Inline handlers are rejected at render time (the default).
    case disabled
    /// Inline handlers are stored in memory, bounded by `ttl` and `capacity`.
    ///
    /// - Parameters:
    ///   - ttl: How long a rendered handler stays pressable.
    ///   - capacity: Maximum number of live handlers; the oldest are evicted
    ///     first once it is reached.
    ///   - expired: Response for a press whose handler is gone — expired,
    ///     evicted, lost to a restart, or pressed by someone outside its
    ///     scope. Use `.unhandled` to let the update fall through to
    ///     `router.unmatched` instead.
    case enabled(
        ttl: Duration = .seconds(1800),
        capacity: Int = 10_000,
        expired: TelerouteResponse = .answerCallback("This button has expired.")
    )

    var isEnabled: Bool {
        if case .disabled = self { return false }
        return true
    }
}

// MARK: - Store

/// The callback route every inline handler is dispatched through. Short on
/// purpose: it is prepended to each button's `callback_data`, which Telegram
/// caps at 64 bytes.
let telerouteInlineActionPath = "_ta/{id}"

/// Handler invoked when a button with an inline action is pressed.
typealias TelerouteInlineAction = @Sendable (TelerouteContext) async throws -> TelerouteResponse

/// In-memory registry mapping generated button ids to their handlers.
///
/// Rendering a button inserts; pressing it looks up. Entries are bounded both
/// by age and by count, because a long-running bot renders far more buttons
/// than its users ever press.
final class TelerouteInlineActionStore: Sendable {
    struct Entry: Sendable {
        let action: TelerouteInlineAction
        let scope: TelerouteInlineActionScope
        let completion: TelerouteButtonCompletion
        let chatId: Int64?
        let userId: Int64?
        let createdAt: ContinuousClock.Instant
    }

    private struct State {
        /// Ordered by insertion, so eviction pops from the front.
        var entries: OrderedDictionary<String, Entry> = [:]
    }

    private let state = Mutex(State())
    let ttl: Duration
    let capacity: Int
    let expired: TelerouteResponse

    init(ttl: Duration, capacity: Int, expired: TelerouteResponse) {
        self.ttl = ttl
        self.capacity = max(1, capacity)
        self.expired = expired
    }

    /// Stores a handler and returns the id to encode in the button.
    func insert(
        action: @escaping TelerouteInlineAction,
        scope: TelerouteInlineActionScope,
        completion: TelerouteButtonCompletion = .keep,
        chatId: Int64?,
        userId: Int64?,
        now: ContinuousClock.Instant = .now
    ) -> String {
        let id = Self.makeIdentifier()
        let entry = Entry(
            action: action,
            scope: scope,
            completion: completion,
            chatId: chatId,
            userId: userId,
            createdAt: now
        )
        self.state.withLock { state in
            Self.removeExpired(from: &state, ttl: self.ttl, now: now)
            state.entries[id] = entry
            while state.entries.count > self.capacity {
                state.entries.removeFirst()
            }
        }
        return id
    }

    /// Returns the handler for `id` when it is live and `press` is in scope.
    ///
    /// A miss, an expiry, and an out-of-scope press are deliberately
    /// indistinguishable to the caller: telling them apart would let a button
    /// report whether someone else's session exists.
    func entry(
        for id: String,
        pressedBy press: (chatId: Int64?, userId: Int64?),
        now: ContinuousClock.Instant = .now
    ) -> Entry? {
        self.state.withLock { state in
            Self.removeExpired(from: &state, ttl: self.ttl, now: now)
            guard let entry = state.entries[id] else { return nil }
            guard Self.isInScope(entry, press: press) else { return nil }
            return entry
        }
    }

    func action(
        for id: String,
        pressedBy press: (chatId: Int64?, userId: Int64?),
        now: ContinuousClock.Instant = .now
    ) -> TelerouteInlineAction? {
        self.entry(for: id, pressedBy: press, now: now)?.action
    }

    /// Drops entries older than the TTL. Called on every access, so a bot that
    /// keeps rendering buttons never accumulates dead ones even if the
    /// periodic sweep is not running.
    func removeExpired(now: ContinuousClock.Instant = .now) {
        self.state.withLock { Self.removeExpired(from: &$0, ttl: self.ttl, now: now) }
    }

    var count: Int {
        self.state.withLock { $0.entries.count }
    }

    private static func removeExpired(
        from state: inout State,
        ttl: Duration,
        now: ContinuousClock.Instant
    ) {
        // Insertion-ordered, so the live entries are always a suffix.
        while let first = state.entries.elements.first,
              first.value.createdAt.duration(to: now) > ttl {
            state.entries.removeFirst()
        }
    }

    private static func isInScope(
        _ entry: Entry,
        press: (chatId: Int64?, userId: Int64?)
    ) -> Bool {
        switch entry.scope {
        case .anyone:
            true
        case .chat:
            entry.chatId == nil || entry.chatId == press.chatId
        case .user:
            (entry.chatId == nil || entry.chatId == press.chatId)
                && (entry.userId == nil || entry.userId == press.userId)
        }
    }

    /// 16 random bytes in base64url — no `/` and no characters that percent
    /// encoding would expand, so `_ta/<id>` stays 26 bytes.
    private static func makeIdentifier() -> String {
        var generator = SystemRandomNumberGenerator()
        var bytes = [UInt8]()
        bytes.reserveCapacity(16)
        for _ in 0..<2 {
            withUnsafeBytes(of: UInt64.random(in: .min ... .max, using: &generator)) {
                bytes.append(contentsOf: $0)
            }
        }
        return Data(bytes)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
