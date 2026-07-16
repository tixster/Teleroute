import Teleroute

/// Self-contained controller mounted into a scope owned by app composition.
struct ModerationRoutes: TelerouteRouteCollection {
    func addRoutes(to routes: ExampleRoutes) {
        routes.command(
            "audit",
            description: "Show moderation diagnostics",
            visibility: [.allChatAdministrators],
            use: self.audit
        )
    }

    private func audit(_ context: ExampleRequestContext) async throws -> TelerouteResponse {
        .reply("Moderation audit ready (\(context.requestID)).")
    }
}
