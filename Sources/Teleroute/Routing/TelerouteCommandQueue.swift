import AsyncAlgorithms
import Foundation

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

actor TelerouteCommandQueue {
    private struct Worker: Sendable {
        let channel: AsyncChannel<TelerouteQueuedOperation>
        let task: Task<Void, Never>
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
        for worker in self.workers.values {
            worker.channel.finish()
            worker.task.cancel()
        }
    }

    func enqueue<Value: Sendable>(
        key: String,
        operation: @escaping @Sendable () async throws -> Value
    ) async throws -> Value {
        try await withCheckedThrowingContinuation { continuation in
            Task {
                await self.submit(
                    key: key,
                    operation: operation,
                    continuation: continuation
                )
            }
        }
    }

    private func submit<Value: Sendable>(
        key: String,
        operation: @escaping @Sendable () async throws -> Value,
        continuation: CheckedContinuation<Value, any Error>
    ) async {
        self.removeIdleWorkers()
        let now = self.clock.now
        var worker = self.workers[key] ?? self.makeWorker(lastActivity: now)
        worker.pendingCount += 1
        worker.lastActivity = now
        self.workers[key] = worker

        let queuedOperation = TelerouteQueuedOperation { [weak self] in
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
        let task = Task {
            for await operation in channel {
                await operation.run()
            }
        }
        return .init(
            channel: channel,
            task: task,
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
            self.workers[key] = nil
        }
    }
}

private struct TelerouteQueuedOperation: Sendable {
    let run: @Sendable () async -> Void
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
