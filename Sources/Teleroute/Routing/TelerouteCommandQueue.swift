import AsyncAlgorithms
import Foundation
import Synchronization

/// Queueing strategy for command handlers.
public enum TelerouteCommandQueueing: Sendable {
    /// Queue all invocations of the command globally.
    case global
    /// Queue invocations of the command per chat.
    case chat
    /// Queue invocations of the command per chat and user.
    case chatUser

    func key(routeName: String, context: TelerouteContext) -> String {
        switch self {
        case .global:
            return "global|\(routeName)"
        case .chat:
            return "chat|\(routeName)|\(context.chatId.map(String.init) ?? "none")"
        case .chatUser:
            return "chatUser|\(routeName)|\(context.chatId.map(String.init) ?? "none")|\(context.userId.map(String.init) ?? "none")"
        }
    }
}

/// Idempotent, lock-protected wrapper around a single caller continuation.
///
/// The continuation is resumed exactly once regardless of how many times
/// `cancel()` is called (caller cancellation, worker teardown, or queue
/// deallocation). The operation body owns the success/error resume path.
private final class TeleroutePendingSlot: @unchecked Sendable {
    private enum Status {
        case pending(@Sendable () -> Void)
        case resumed
    }

    private let state = Mutex<Status>(.resumed)

    /// Stores the resume closure the first time. Subsequent `store` calls are
    /// ignored so the slot keeps exactly one resume.
    func store(_ resume: @escaping @Sendable () -> Void) {
        self.state.withLock { status in
            if case .resumed = status {
                status = .pending(resume)
            }
        }
    }

    /// Invokes the stored resume closure if it has not been invoked yet.
    /// Returns `true` when this call performed the resume.
    @discardableResult
    func cancel() -> Bool {
        let resume = self.state.withLock { status -> (@Sendable () -> Void)? in
            guard case let .pending(resume) = status else { return nil }
            status = .resumed
            return resume
        }
        resume?()
        return resume != nil
    }

    /// Claims the slot for normal completion. Returns `false` when the
    /// continuation has already been resumed by cancellation, in which case
    /// the operation body must not resume it again.
    func tryClaim() -> Bool {
        self.state.withLock { status in
            guard case .pending = status else { return false }
            status = .resumed
            return true
        }
    }
}

actor TelerouteCommandQueue {
    private struct Worker: Sendable {
        let channel: AsyncChannel<TelerouteQueuedOperation>
        let task: Task<Void, Never>
        /// Cancellation slots for callers whose operations have not started yet.
        /// Resumed with `CancellationError` during worker teardown.
        let pendingSlots: TeleroutePendingSlots
        var pendingCount: Int
        var lastActivity: ContinuousClock.Instant
    }

    private let clock = ContinuousClock()
    private let workerIdleTimeout: Duration
    private var workers: [String: Worker] = [:]

    init(
        workerIdleTimeout: Duration = .seconds(30)
    ) {
        self.workerIdleTimeout = workerIdleTimeout
    }

    deinit {
        // Each worker holds Sendable resources, so touching them off-actor here
        // is safe. Pending callers are resumed with cancellation instead of
        // hanging forever after the queue is deallocated.
        for worker in self.workers.values {
            worker.channel.finish()
            worker.task.cancel()
            worker.pendingSlots.cancelAll()
        }
    }

    func enqueue<Value: Sendable>(
        key: String,
        operation: @escaping @Sendable () async throws -> Value
    ) async throws -> Value {
        // Cancellation slot shared between the caller's cancellation handler
        // (which fires when the caller's task is cancelled) and the worker that
        // owns this operation (which fires on worker teardown). The slot wraps
        // the continuation so whichever side wins, it is resumed exactly once.
        let slot = TeleroutePendingSlot()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                slot.store { continuation.resume(throwing: CancellationError()) }
                Task { [weak self] in
                    await self?.submit(
                        key: key,
                        slot: slot,
                        operation: operation,
                        continuation: continuation
                    )
                }
            }
        } onCancel: {
            // Caller cancelled (possibly before `submit` even ran). Resume the
            // continuation with cancellation if the operation has not started.
            slot.cancel()
        }
    }

    private func submit<Value: Sendable>(
        key: String,
        slot: TeleroutePendingSlot,
        operation: @escaping @Sendable () async throws -> Value,
        continuation: CheckedContinuation<Value, any Error>
    ) async {
        self.removeIdleWorkers()
        let now = self.clock.now
        var worker = self.workers[key] ?? self.makeWorker(lastActivity: now)
        worker.pendingCount += 1
        worker.lastActivity = now
        self.workers[key] = worker

        worker.pendingSlots.register(slot)

        let pendingSlots = worker.pendingSlots
        let queuedOperation = TelerouteQueuedOperation { [weak self] in
            // Operation is starting: remove it from the pending set so teardown
            // no longer races to cancel it, then claim the slot. If the caller
            // already cancelled (and resumed the continuation), bail out.
            pendingSlots.unregister(slot)
            guard slot.tryClaim() else {
                await self?.finishOperation(key: key)
                return
            }
            do {
                continuation.resume(returning: try await operation())
            } catch {
                continuation.resume(throwing: error)
            }
            await self?.finishOperation(key: key)
        }

        await worker.channel.send(queuedOperation)
    }

    private func makeWorker(lastActivity: ContinuousClock.Instant) -> Worker {
        let channel = AsyncChannel<TelerouteQueuedOperation>()
        let pendingSlots = TeleroutePendingSlots()
        let task = Task {
            for await operation in channel {
                await operation.run()
            }
        }
        return .init(
            channel: channel,
            task: task,
            pendingSlots: pendingSlots,
            pendingCount: 0,
            lastActivity: lastActivity
        )
    }

    private func finishOperation(key: String) {
        guard var worker = self.workers[key] else { return }
        worker.pendingCount = max(0, worker.pendingCount - 1)
        worker.lastActivity = self.clock.now
        self.workers[key] = worker
    }

    private func removeIdleWorkers() {
        let now = self.clock.now
        for (key, worker) in self.workers {
            guard worker.pendingCount == 0,
                  worker.lastActivity.duration(to: now) >= self.workerIdleTimeout else {
                continue
            }
            worker.channel.finish()
            worker.task.cancel()
            worker.pendingSlots.cancelAll()
            self.workers[key] = nil
        }
    }
}

private struct TelerouteQueuedOperation: Sendable {
    let run: @Sendable () async -> Void
}

/// Set of pending cancellation slots for a worker. Identity-based to allow
/// `unregister` to remove a single slot once its operation starts.
private final class TeleroutePendingSlots: @unchecked Sendable {
    private struct Box: Sendable {
        var slots: [ObjectIdentifier: TeleroutePendingSlot] = [:]
    }

    private let state = Mutex(Box())

    func register(_ slot: TeleroutePendingSlot) {
        self.state.withLock { $0.slots[ObjectIdentifier(slot)] = slot }
    }

    func unregister(_ slot: TeleroutePendingSlot) {
        self.state.withLock { _ = $0.slots.removeValue(forKey: ObjectIdentifier(slot)) }
    }

    @discardableResult
    func cancelAll() -> Int {
        self.state.withLock {
            let count = $0.slots.count
            for slot in $0.slots.values {
                slot.cancel()
            }
            $0.slots.removeAll()
            return count
        }
    }
}

struct TelerouteCommandQueueMiddleware: TelerouteMiddleware, Sendable {
    let queue: TelerouteCommandQueue
    let routeName: String
    let queueing: TelerouteCommandQueueing

    func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) async throws {
        let key = self.queueing.key(routeName: self.routeName, context: context)
        try await self.queue.enqueue(key: key) {
            try await next(context)
        }
    }
}

enum TelerouteFlowQueueKey: Sendable {
    static func key(for flowKey: TelerouteFlowKey) -> String {
        "flow|\(flowKey.chatId)|\(flowKey.userId.map(String.init) ?? "none")"
    }
}

struct TelerouteFlowQueueMiddleware: TelerouteMiddleware, Sendable {
    let queue: TelerouteCommandQueue

    func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) async throws {
        guard let flowKey = context.flowKey else {
            try await next(context)
            return
        }

        try await self.queue.enqueue(key: TelerouteFlowQueueKey.key(for: flowKey)) {
            try await next(context)
        }
    }
}
