import Foundation

/// Immutable middleware chain compiled once when its route is registered.
///
/// Steps return a ``TelerouteResponse``; `.unhandled` falls through to the
/// next candidate route, anything else marks the route handled and is
/// executed after the chain unwinds (so middleware can observe and rewrite
/// the response value before its side effects run).
struct TelerouteRouteExecutor: Sendable {
    private typealias Step = @Sendable (
        _ context: TelerouteContext
    ) async throws -> TelerouteResponse

    private let firstStep: Step

    init(
        middlewares: [any TelerouteMiddleware<TelerouteContext>],
        handler: @escaping TelerouteHandler
    ) {
        var next: Step = { context in
            try await handler(context)
        }

        for middleware in middlewares.reversed() {
            let downstream = next
            next = { context in
                try await middleware.handle(context, next: downstream)
            }
        }
        self.firstStep = next
    }

    /// Runs the chain; returns whether the route handled the update.
    func run(context: TelerouteContext) async throws -> Bool {
        let response = try await self.firstStep(context)
        if response.isUnhandled {
            return false
        }
        try await response.execute(in: context)
        return true
    }
}
