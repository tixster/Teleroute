import Teleroute

typealias ExampleRoutes = TelerouteRouterGroup<ExampleRequestContext>
typealias ExampleUserRoutes = TelerouteRouterGroup<ExampleUserContext>

/// Application-specific context created once for every matched route.
struct ExampleRequestContext: TelerouteInitializableRequestContext {
    let coreContext: TelerouteContext
    var requestID: String

    init(source: TelerouteContextSource) {
        self.coreContext = source.coreContext
        self.requestID = "pending"
    }
}

/// Context middleware can transform typed context values before handlers run.
struct ExampleRequestIDMiddleware: TelerouteMiddleware {
    typealias Context = ExampleRequestContext

    func handle(
        _ context: ExampleRequestContext,
        next: @escaping @Sendable (ExampleRequestContext) async throws -> TelerouteResponse
    ) async throws -> TelerouteResponse {
        var context = context
        context.requestID = "update-\(context.update.updateId)"
        return try await next(context)
    }
}

/// Child context guarantees that nested handlers have a Telegram user ID.
struct ExampleUserContext: TelerouteChildRequestContext {
    typealias ParentContext = ExampleRequestContext

    let coreContext: TelerouteContext
    let requestID: String
    let userID: Int64

    init(context: ExampleRequestContext) throws {
        guard let userID = context.userId else {
            throw ExampleError.userMissing
        }
        self.coreContext = context.coreContext
        self.requestID = context.requestID
        self.userID = userID
    }
}
