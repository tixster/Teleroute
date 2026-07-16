import Foundation
import Synchronization

/// Immutable middleware chain compiled once when its route is registered.
struct TelerouteRouteExecutor: Sendable {
    private typealias Step = @Sendable (
        _ context: TelerouteContext,
        _ state: TelerouteRouteExecutionState
    ) async throws -> Void

    private let firstStep: Step

    init(
        middlewares: [any TelerouteMiddleware],
        handler: @escaping TelerouteHandler
    ) {
        var next: Step = { context, state in
            state.markHandled()
            try await handler(context)
        }

        for middleware in middlewares.reversed() {
            let downstream = next
            let consumesWithoutCallingNext = middleware is any TelerouteConsumingMiddleware
            next = { context, state in
                let didCallNext = Mutex(false)
                try await middleware.handle(context) { nextContext in
                    didCallNext.withLock { $0 = true }
                    try await downstream(nextContext, state)
                }
                if didCallNext.withLock({ $0 }) == false,
                   consumesWithoutCallingNext {
                    state.markHandled()
                }
            }
        }
        self.firstStep = next
    }

    func run(context: TelerouteContext) async throws -> Bool {
        let state = TelerouteRouteExecutionState()
        try await self.firstStep(context, state)
        return state.isHandled
    }
}

private final class TelerouteRouteExecutionState: Sendable {
    private let handled = Mutex(false)

    func markHandled() {
        self.handled.withLock { $0 = true }
    }

    var isHandled: Bool {
        self.handled.withLock { $0 }
    }
}
