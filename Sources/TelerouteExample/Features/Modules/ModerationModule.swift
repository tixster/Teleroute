import Teleroute

/// Self-contained controller mounted into a scope owned by app composition.
struct ModerationModule: TelerouteModule {
    func register(in routes: TelerouteRoutes) {
        routes.command(
            "audit",
            description: "Show moderation diagnostics",
            visibility: [.allChatAdministrators],
            use: self.audit
        )
    }

    private func audit(_ context: TelerouteContext) async throws {
        try await context.reply("Moderation audit ready.")
    }
}
