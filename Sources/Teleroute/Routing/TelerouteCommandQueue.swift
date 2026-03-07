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
    private var nextIdentifier = 0
    private var tasks: [String: (identifier: Int, task: Task<Void, any Error>)] = [:]

    func enqueue(
        key: String,
        operation: @escaping @Sendable () async throws -> Void
    ) async throws {
        let previous = self.tasks[key]?.task
        let identifier = self.nextIdentifier
        self.nextIdentifier += 1

        let task = Task {
            _ = try? await previous?.value
            try await operation()
        }

        self.tasks[key] = (identifier, task)

        defer {
            if self.tasks[key]?.identifier == identifier {
                self.tasks[key] = nil
            }
        }

        try await task.value
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
